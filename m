From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 03 Aug 2006 17:37:41 +0200
Message-ID: <44D21845.6020703@arndnet.de>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru>
 <44D20A2F.3090005@arndnet.de> <20060803150330.GB12915@2ka.mipt.ru>
 <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl>
 <20060803151631.GA14774@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7BIT
Cc: Krzysztof Oledzki <olel@ans.pl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-2.rz.RWTH-Aachen.DE ([134.130.3.131]:1482 "EHLO
	ms-dienst.rz.rwth-aachen.de") by vger.kernel.org with ESMTP
	id S964801AbWHCPhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 11:37:35 -0400
Received: from circe (circe.rz.RWTH-Aachen.DE [134.130.3.36])
 by ms-dienst.rz.rwth-aachen.de
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0J3F00HE7I2K9T@ms-dienst.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Aug 2006 17:37:33 +0200 (MEST)
Received: from dustpuppy.kawo2.rwth-aachen.de
 (dustpuppy.kawo2.RWTH-Aachen.DE [134.130.180.5])	by smarthost.rwth-aachen.de
 (8.13.7/8.13.1/1) with ESMTP id k73FbVxN014722	for <netdev@vger.kernel.org>;
 Thu, 03 Aug 2006 17:37:31 +0200
Received: from dustpuppy.kawo2.rwth-aachen.de (localhost [127.0.0.1])
	by dustpuppy.kawo2.rwth-aachen.de (Postfix) with ESMTP id B8A3E1FC297	for
 <netdev@vger.kernel.org>; Thu, 03 Aug 2006 17:37:31 +0200 (CEST)
In-reply-to: <20060803151631.GA14774@2ka.mipt.ru>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Evgeniy Polyakov wrote:
> On Thu, Aug 03, 2006 at 05:08:51PM +0200, Krzysztof Oledzki (olel@ans.pl) wrote:
>>>> Why? After your explanation that makes sense for me. The driver needs
>>>> one contiguous chunk for those 9k packet buffer and thus requests a
>>>> 3-order page of 16k. Or do i still do not understand this?
>>> Correct, except that it wants 32k.
>>> e1000 logic is following:
>>> align frame size to power-of-two,
>> 16K?
> 
> Yep.
> 
>>> then skb_alloc adds a little
>>> (sizeof(struct skb_shared_info)) at the end, and this ends up
>>> in 32k request just for 9k jumbo frame.
>> Strange, why this skb_shared_info cannon be added before first alignment? 
>> And what about smaller frames like 1500, does this driver behave similar 
>> (first align then add)?
> 
> It can be.
> Could attached  (completely untested) patch help?

I will try this in a minute. However is there any way to see which
allocation e1000 does without triggering allocation failures? ;-)

Thanks,
Arnd Hannemann


