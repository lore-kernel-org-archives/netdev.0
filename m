From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate
 module unloading
Date: Thu, 15 Aug 2013 09:27:53 +0200
Message-ID: <20130815092753.5a23810b@mitra.spranger.biz>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
	<1376384922-8519-3-git-send-email-b.spranger@linutronix.de>
	<20130813174814.GE4098@kroah.com>
	<20130814091946.2643a124@mitra.spranger.biz>
	<20130814163311.GB7208@kroah.com>
	<20130815084221.3339142f@mitra.spranger.biz>
	<20130815065936.GA13320@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:60919 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760486Ab3HOH15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 03:27:57 -0400
In-Reply-To: <20130815065936.GA13320@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Aug 2013 23:59:36 -0700
Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:

> Hm.  Ah, doesn't this work like PCI, when a PCI device is removed from
> the system, reads just start returning all 0xFF, so the userspace UIO
> driver now knows the device is gone from the system.  Doesn't MFD
> hardware work the same way?  Why would removing the MFD driver affect
> UIO at all, as it's just an interrupt and memory, both of which are
> controlled by UIO, not MFD at all.
> 
> confused,
Sorry for the confusion.

MFD core allocates the platform device structure and platform data
dynamicaly and fill it up with appropriate data from the MFD cell data.
And MFD core frees this memory on unregistering.

Therefore the UIO driver needs to know that the underlaying platform device
struct and platform device data are invalid and should not be used any more.
The whole point are dynamicaly allocated devices and UIO.

Regards
    Benedikt Spranger
