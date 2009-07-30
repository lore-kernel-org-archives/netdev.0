From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pcnet32: VLB support fixes
Date: Thu, 30 Jul 2009 17:32:19 -0400
Message-ID: <4A721163.7030700@garzik.org>
References: <200907302317.52648.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Don Fry <pcnet32@verizon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dan Carpenter <error27@gmail.com>,
	corbet@lwn.net, eteo@redhat.com, Julia Lawall <julia@diku.dk>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34078 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751855AbZG3VcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2009 17:32:24 -0400
In-Reply-To: <200907302317.52648.bzolnier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Subject: [PATCH] pcnet32: VLB support fixes
> 
> VLB support has been broken since at least 2004-2005 period as some
> changes introduced back then assumed that ->pci_dev is always valid,
> lets try to fix it:
> 
> - remove duplicated SET_NETDEV_DEV() call
> 
> - call SET_NETDEV_DEV() only for PCI devices
> 
> - check for ->pci_dev validity in pcnet32_open()
> 
> [ Alternatively we may consider removing VLB support but there would not
>   be much gain in it since an extra driver code needed for VLB support is
>   minimal and quite simple. ]
> 
> This takes care of the following entry from Dan's list:
> 
> drivers/net/pcnet32.c +1889 pcnet32_probe1(298) warning: variable derefenced before check 'pdev'
> 
> Reported-by: Dan Carpenter <error27@gmail.com>
> Cc: corbet@lwn.net
> Cc: eteo@redhat.com
> Cc: Julia Lawall <julia@diku.dk>
> Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> ---
> PS I still keep the original cc: list from the smatch thread -- please let
> me know if you don't want to be spammed.. ;-)
> 
>  drivers/net/pcnet32.c |   12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)

ACK -- the patch is correct AFAICS -- but would it not be better to have 
a struct device for the VLB device?

We have capability to create struct device for isa and eisa, so VLB is 
quite doable.

	Jeff, who converted old-ISDN ISA+EISA+PCI drivers to
	      hotplug model, once upon a time



