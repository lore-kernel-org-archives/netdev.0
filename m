From: <Parav.Pandit@Emulex.Com>
Subject: RE: [RFC 2/2] be2net: Added functionality to support RoCE driver
Date: Thu, 8 Mar 2012 22:16:13 -0800
Message-ID: <88B766C272F2C64B944B21AD078333151C961A10F5@EXMAIL.ad.emulex.com>
References: <1331142427-23721-1-git-send-email-parav.pandit@emulex.com>
 <1331142427-23721-2-git-send-email-parav.pandit@emulex.com>
 <470f5ea2-9344-42d5-b130-130d90a42250@exht1.ad.emulex.com>
 <20120308114859.GA23807@electric-eye.fr.zoreil.com>
 <3cd7ea39-a8d3-4d63-9753-0c64fb7e3609@exht1.ad.emulex.com>
 <20120308162716.GA31576@electric-eye.fr.zoreil.com>
 <88B766C272F2C64B944B21AD078333151C956BD34F@EXMAIL.ad.emulex.com>
 <20120308194106.GA3008@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:6614 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750707Ab2CIGQg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 01:16:36 -0500
In-Reply-To: <20120308194106.GA3008@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inline.

-----Original Message-----
From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
Sent: Friday, March 09, 2012 1:11 AM
To: Pandit, Parav
Cc: netdev@vger.kernel.org
Subject: Re: [RFC 2/2] be2net: Added functionality to support RoCE driver

Parav.Pandit@Emulex.Com <Parav.Pandit@Emulex.Com> :
> From: Francois Romieu [romieu@fr.zoreil.com]
[...]
> You can init the adequate operations set at dev_add / registration 
> time so that the remaining be_roce_dev_xyz methods turn into noop for 
> NIC without ROCE.
> [Parav] What do we gain by executing NO_OP function, where there is no need to do that?

We do not execute anything for NIC without ROCE.

For the ROCE case, it costs a new set of net_device_ops where the .open() and
.close() callbacks are different from the ones in be_netdev_ops. The former
.open() and .close() call into the latter. The current code does the opposite.

> What is the problem in performing this check and not executing those function? I find it more simpler and clean.

It is not a big problem. ROCE depends on NIC. The implementation exhibits a dependency in the opposite order.

> Also, add(), remove() etc operations are at driver level and not at device level. So with proposed implementation there is no need to store those 3 fn_pointers to device structure.

The functions pointers are already there. The driver .remove() handler can not be replaced but it can exchange the be_roce_supported() test for a !ocrdma_dev test. It should allow to remove if_type from be_adapter as it won't be used beyond .probe() (I only did a quick check).

It is up to you to weigh the net_device_ops cost. If more methods need to be modified for ROCE, the extra layer could be worth it. Your call.

[Parav] I understand your proposed design and benefit if we have more such differences with ROCE vs non ROCE NICs.
In near future those device_specific checks in either way doesn't differ much in either implementation.  So I would like to keep it current way. When we add more features it will be more logical to adopt your newly proposed approach and use different netdev_ops structure.
I'll be addressing other review comments and one specifically to change void* to ocrdma_dev* with forward declaration.

Off for jogging.

--
Ueimor
