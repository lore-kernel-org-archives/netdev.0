From: Roland Dreier <roland@purestorage.com>
Subject: Re: [RFC 2/2] be2net: Added functionality to support RoCE driver
Date: Thu, 8 Mar 2012 10:08:19 -0800
Message-ID: <CAL1RGDWB3jgBMZAiE6guNgFy-QVvh4NBj1sXd6k7eK1hDnv51Q@mail.gmail.com>
References: <1331142427-23721-1-git-send-email-parav.pandit@emulex.com>
 <1331142427-23721-2-git-send-email-parav.pandit@emulex.com>
 <470f5ea2-9344-42d5-b130-130d90a42250@exht1.ad.emulex.com> <20120308114859.GA23807@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: parav.pandit@emulex.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog112.obsmtp.com ([74.125.245.92]:57347 "HELO
	na3sys010aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752862Ab2CHSIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 13:08:40 -0500
Received: by obbuo6 with SMTP id uo6so957996obb.19
        for <netdev@vger.kernel.org>; Thu, 08 Mar 2012 10:08:39 -0800 (PST)
In-Reply-To: <20120308114859.GA23807@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 8, 2012 at 3:48 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Are there real use-cases where the device and the ocrdma_drv could be
> loaded in different relative ordering ?

Yes -- two cases are pretty standard:

 - be2net driver loads, probes all devices, then roce driver loads
 - be2net and roce driver loads, then a device is probed later
   (PCI hotplug, new SR-IOV virtual function, etc)

so we need to deal with the case where both the core be2net driver
is probing devices and the roce driver loads later, and also the case
where the roce driver loads first and then gets notified as the be2net
driver probes a device.

(This is pretty much the same as mlx4_core / mlx4_ib BTW)

 - R.
