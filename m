From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net 2/2] cxgb4: Disable interrupts and napi before unregistering
 netdev
Date: Sat, 28 Mar 2015 05:20:37 +0100
Message-ID: <55162C15.1000807@gmx.de>
References: <1427344466-17658-1-git-send-email-hariprasad@chelsio.com> <1427344466-17658-3-git-send-email-hariprasad@chelsio.com> <551473D6.2050406@gmx.de> <20150327085447.GA20708@hariprasad-pc.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:65313 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842AbbC1EUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Mar 2015 00:20:46 -0400
In-Reply-To: <20150327085447.GA20708@hariprasad-pc.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.03.2015 09:54, Hariprasad S wrote:

>> 
>> just out of curiousity: How can an unregister of a netdevice lead to a
>> crash caused by traffic? I understand that _freeing_ the device or other
>> resources is a bad idea as long as irqs are still active. But unregister
>> should not do anything critical (i am asking since I want to avoid such
>> problems in my own drivers).
>> 
>> Regards,
>> Lino
>> 
> 
> When device is unregistered ip_ptr of net_device structure is set to NULL.
> Since NAPI is not disabled, every packet goes through ip_error() check.
> And in ip_error() function when in_device structure is obtained from netdevice
> structure, it ends up in NULL pointer dereference since ip_ptr is already NULL.
> 
> Regards,
> Hari
> 

Ah ok, that makes sense. I missed the cleanup done due to netdev
notifier calls (in this case ip_netdev_notifier). Thanks for pointing
this out.

Regards,
Lino
