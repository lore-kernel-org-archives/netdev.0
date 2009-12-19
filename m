From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] improve netem reorder flexibility
Date: Fri, 18 Dec 2009 19:59:07 -0800 (PST)
Message-ID: <20091218.195907.189689401.davem@davemloft.net>
References: <1261142318-26249-1-git-send-email-christian.samsel@rwth-aachen.de>
	<20091218093240.64ca7d88@nehalam>
	<200912181901.28542.christian.samsel@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: christian.samsel@rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42863
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753998AbZLSD7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 22:59:06 -0500
In-Reply-To: <200912181901.28542.christian.samsel@rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Samsel <christian.samsel@rwth-aachen.de>
Date: Fri, 18 Dec 2009 19:01:28 +0100

> Am Freitag, 18. Dezember 2009 18:32:40 schrieb Stephen Hemminger:
>> On Fri, 18 Dec 2009 14:18:37 +0100
>> 
>> Christian Samsel <christian.samsel@rwth-aachen.de> wrote:
>> > This patch adds a new feature to netem: The newly introduced parameter
>> > reorderdelay TIME is the time a reordered packet is delayed. It can be
>> > used in a combination with delay TIME to enable netem to produce late
>> > packets, which is not possible in the standard netem / iproute2. In the
>> > standard version reordered packets are always sent immediately and
>> > therefore are always early packets.
>> 
>> I like the idea but is it binary compatible with older kernels/ older
>>  iproute2 utilities?
>> 
> Thats a good point. I will test it. So far i think it should work.

It won't work.

If you change the size of the tc_netem_qopt, older kernels will
reject because the size is different from what the kernel expects.

So newer iproute2 will not work with older kernels.

You can't change these structures, add new netlink attributes
to pass the new data instead.
