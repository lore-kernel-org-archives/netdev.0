From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: reset reordering est. selectively on
 timeout
Date: Tue, 13 Aug 2013 16:08:51 -0700 (PDT)
Message-ID: <20130813.160851.329709982935426258.davem@davemloft.net>
References: <1376350885-32407-1-git-send-email-ycheng@google.com>
	<CADVnQykaYF5xQJbv-m6d3xKMHSYZQVjmua2CqXkGdwdo_iqSwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, edumazet@google.com, mattmathis@google.com,
	netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755605Ab3HMXIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 19:08:52 -0400
In-Reply-To: <CADVnQykaYF5xQJbv-m6d3xKMHSYZQVjmua2CqXkGdwdo_iqSwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 13 Aug 2013 00:16:57 -0400

> On Mon, Aug 12, 2013 at 7:41 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> On timeout the TCP sender unconditionally reset the estimated
>> degree of network reordering (tp->reordering). This idea behind
>> is that the estimate is too large to trigger fast recovery
>> (e.g., due to a IP path change).
>>
>> But for example if the sender only had 2 packets outstanding,
>> then a timeout doesn't tell much about reordering. A sender that
>> learns about reordering on big writes and lose packets on small
>> writes will end up falsely retransmit again and again, especially
>> when reordering is more likely on big writes.
>>
>> Therefore the sender should only suspects tp->reordering is too
>> high if it could have gone into fast recovery with the (lower)
>> default estimate.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> ---
>>  net/ipv4/tcp_input.c | 9 +++++++--
>>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks.
