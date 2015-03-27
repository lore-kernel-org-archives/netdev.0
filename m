From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net 2/2] cxgb4: Disable interrupts and napi before
 unregistering netdev
Date: Fri, 27 Mar 2015 14:24:49 +0530
Message-ID: <20150327085447.GA20708@hariprasad-pc.asicdesigners.com>
References: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com>
 <1427344466-17658-3-git-send-email-hariprasad@chelsio.com>
 <551473D6.2050406@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<leedom@chelsio.com>, <anish@chelsio.com>, <nirranjan@chelsio.com>,
	<kumaras@chelsio.com>, <swise@opengridcomputing.com>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8196 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbbC0IzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 04:55:00 -0400
Content-Disposition: inline
In-Reply-To: <551473D6.2050406@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2015 at 22:02:14 +0100, Lino Sanfilippo wrote:
> Hi,
> 
> On 26.03.2015 05:34, Hariprasad Shenai wrote:
> > Disable interrupts and quiesce rx before unregistering net device to avoid crash
> > while unloading driver when traffic is flowing through.
> > 
> > Based on original work by Shameem Khalid <shameem@chelsio.com>
> > 
> 
> just out of curiousity: How can an unregister of a netdevice lead to a
> crash caused by traffic? I understand that _freeing_ the device or other
> resources is a bad idea as long as irqs are still active. But unregister
> should not do anything critical (i am asking since I want to avoid such
> problems in my own drivers).
> 
> Regards,
> Lino
> 

When device is unregistered ip_ptr of net_device structure is set to NULL.
Since NAPI is not disabled, every packet goes through ip_error() check.
And in ip_error() function when in_device structure is obtained from netdevice
structure, it ends up in NULL pointer dereference since ip_ptr is already NULL.

Regards,
Hari
