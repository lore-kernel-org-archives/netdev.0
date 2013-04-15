From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: don't bypass encapsulation for multi-
 and broadcasts
Date: Mon, 15 Apr 2013 01:45:30 -0400 (EDT)
Message-ID: <20130415.014530.1175856229390286987.davem@davemloft.net>
References: <1365931311-26285-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20130414.153950.1876060927096209566.davem@davemloft.net>
	<CAF1J0HMoSY4b4RWDPW3yRmXovBcot_1UMo4QJkbg43KJxTWPkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: mike.rapoport@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675Ab3DOFpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 01:45:34 -0400
In-Reply-To: <CAF1J0HMoSY4b4RWDPW3yRmXovBcot_1UMo4QJkbg43KJxTWPkg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Mon, 15 Apr 2013 08:31:15 +0300

> On Sun, Apr 14, 2013 at 10:39 PM, David Miller <davem@davemloft.net> wrote:
>> From: Mike Rapoport <mike.rapoport@ravellosystems.com>
>> Date: Sun, 14 Apr 2013 12:21:51 +0300
>>
>>> The multicast and broadcast packets may have RTCF_LOCAL set in rt_flags
>>> and therefore will be sent out bypassing encapsulation. This breaks
>>> delivery of packets sent to the vxlan multicast group.
>>> Disabling encapsulation bypass for multicasts and broadcasts fixes the
>>> issue.
>>>
>>> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
>>
>> This still won't handle the case of encapsulations occuring in different
>> namespaces or virtual machines.
>>
>> I really want this fixed correctly.
> 
> I'm sorry, but I don't quite follow you. The patch does not aim to
> reduce the amount of encapsulation. On the contrary, it prevents some
> packets from being encapsulated when they should not be...

I'm saying you need to make sure the bypass is avoided in these
situations as well.

There is an ongoing discussion about this on the list between Cong
Wang and the author of the bypass changes.
