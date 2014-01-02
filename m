From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: question about tulip/winbond-840.c
Date: Thu, 2 Jan 2014 07:37:54 -0800
Message-ID: <CAP6odjj2jPfgEBdHv+GGDhVaHt4KEm_DWCX3PdCxCjUbApWc8Q@mail.gmail.com>
References: <alpine.DEB.2.10.1401021520280.2088@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:44775 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbaABPh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 10:37:56 -0500
Received: by mail-oa0-f52.google.com with SMTP id h16so14898882oag.39
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 07:37:55 -0800 (PST)
In-Reply-To: <alpine.DEB.2.10.1401021520280.2088@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 6:24 AM, Julia Lawall <julia.lawall@lip6.fr> wrote:
> I don't know if you want to bother about this, because it is very old code
> and is apparently not hurting anyone, but I don't see the point of the
> call to pci_enable_device in the function w840_resume.

I believe the call to pci_enable_device is required:
    http://lxr.free-electrons.com/source/Documentation/PCI/pci.txt


254 3.1 Enable the PCI device
255 ~~~~~~~~~~~~~~~~~~~~~~~~~
256 Before touching any device registers, the driver needs to enable
257 the PCI device by calling pci_enable_device(). This will:
258         o wake up the device if it was in suspended state,
259         o allocate I/O and memory regions of the device (if BIOS did not),
260         o allocate an IRQ (if BIOS did not).

> The driver had a
> call to pci_enable_device in its probe function, but it contains no call
> to pci_disable_device, unlike some other tulip drivers.

I think the bug is the pci_disable_device is not called. The driver
should call pci_disable_device in suspend function and on failure path
in the resume function. I've never looked at this code before and I
believe has existed before PCI API was "mature". That's probably why
it's not using the API correctly.

>  Perhaps the call has a small functionality,

Yes - assuming pci.txt isn't stale. :)

> but it seems like it can at least never return
> a value other than 0, because the result of
> atomic_inc_return(&dev->enable_cnt) in pci_enable_device_flags should
> be greater than 1.

Off hand I don't recall..pci_enable_device used to setup alot more
stuff including power state and many of those could fail.


>
> julia
