From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 14:56:27 -0400 (EDT)
Message-ID: <20130321.145627.565133121162775865.davem@davemloft.net>
References: <20130321.114616.279859400813363663.davem@davemloft.net>
	<1363882091.4431.20.camel@edumazet-glaptop>
	<CAM8tLiMbSQZZW0NBPXGgdHRSJ8UqH+q=QaR+2KOqsf-gt6RHGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dmitry@broadcom.com, eilong@broadcom.com, pshelar@nicira.com,
	hkchu@google.com, maze@google.com
To: dkravkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45892 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643Ab3CUS4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 14:56:30 -0400
In-Reply-To: <CAM8tLiMbSQZZW0NBPXGgdHRSJ8UqH+q=QaR+2KOqsf-gt6RHGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dkravkov@gmail.com>
Date: Thu, 21 Mar 2013 20:11:37 +0200

>> Well, I suspect this hardware is not capable of doing the proper ID
>> manipulation twice. (inner and outer header)
> 
> This is correct: ID only for one of the headers can be handled with
> current FW/HW, for other DF is set.

DF does not matter.

Regardless of DF, we must set the ID field correctly.

It is abundantly clear that the current GRE tunnel segmentation
is not generating packets according to our well documented
rules, in that we must be able to precisely create exactly
the original packet stream from the segmented frame.

Someone needs to send me patches to revert the bnx2x GRE segmentation
support, and any software implementation in our tree that has the same
bug.

If someone doesn't do it, I will revert all of this code myself.  You
simply will have to cope with not having this optimization until
your hardware can do it properly and according to our well established
rules for segmentation offloads.

Thanks.
