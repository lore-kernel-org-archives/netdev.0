From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [PATCH] pcnet32: VLB support fixes
Date: Fri, 31 Jul 2009 00:25:44 +0200
Message-ID: <200907310025.44576.bzolnier@gmail.com>
References: <200907302317.52648.bzolnier@gmail.com> <200907302346.26017.bzolnier@gmail.com> <4A721768.2060102@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Don Fry <pcnet32@verizon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dan Carpenter <error27@gmail.com>,
	corbet@lwn.net, eteo@redhat.com, Julia Lawall <julia@diku.dk>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:52274 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbZG3W0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 18:26:51 -0400
In-Reply-To: <4A721768.2060102@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 30 July 2009 23:58:00 Jeff Garzik wrote:
> Bartlomiej Zolnierkiewicz wrote:
> > On Thursday 30 July 2009 23:32:19 Jeff Garzik wrote:
> >> Bartlomiej Zolnierkiewicz wrote:
> >>> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> >>> Subject: [PATCH] pcnet32: VLB support fixes
> >>>
> >>> VLB support has been broken since at least 2004-2005 period as some
> >>> changes introduced back then assumed that ->pci_dev is always valid,
> >>> lets try to fix it:
> >>>
> >>> - remove duplicated SET_NETDEV_DEV() call
> >>>
> >>> - call SET_NETDEV_DEV() only for PCI devices
> >>>
> >>> - check for ->pci_dev validity in pcnet32_open()
> >>>
> >>> [ Alternatively we may consider removing VLB support but there would not
> >>>   be much gain in it since an extra driver code needed for VLB support is
> >>>   minimal and quite simple. ]
> >>>
> >>> This takes care of the following entry from Dan's list:
> >>>
> >>> drivers/net/pcnet32.c +1889 pcnet32_probe1(298) warning: variable derefenced before check 'pdev'
> >>>
> >>> Reported-by: Dan Carpenter <error27@gmail.com>
> >>> Cc: corbet@lwn.net
> >>> Cc: eteo@redhat.com
> >>> Cc: Julia Lawall <julia@diku.dk>
> >>> Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> >>> ---
> >>> PS I still keep the original cc: list from the smatch thread -- please let
> >>> me know if you don't want to be spammed.. ;-)
> >>>
> >>>  drivers/net/pcnet32.c |   12 +++++++-----
> >>>  1 file changed, 7 insertions(+), 5 deletions(-)
> >> ACK -- the patch is correct AFAICS -- but would it not be better to have 
> >> a struct device for the VLB device?
> > 
> > Sure, such addition would be needed for sysfs support on VLB devices..
> 
> 
> >> We have capability to create struct device for isa and eisa, so VLB is 
> >> quite doable.
> >>
> >> 	Jeff, who converted old-ISDN ISA+EISA+PCI drivers to
> >> 	      hotplug model, once upon a time
> > 
> > ..and it seems that you've the needed experience! :)
> 
> <grin>  In my esteemed experience, I point you to the 39-line 
> include/linux/isa.h as a starting point for grep...  :)

Send patches.

I don't have a time/motivation for enhancing VLB support, not even
mentioning the access to hardware needed to test such changes..
