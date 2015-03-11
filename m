From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 2/2] tcp: restore 1.5x per RTT limit to CUBIC cwnd
 growth in congestion avoidance
Date: Wed, 11 Mar 2015 18:10:42 -0400
Message-ID: <CADVnQy=5_8tY+_7k+LcUC=MBtbBnSMeS2yq6na51Qx6Ex=b_Tw@mail.gmail.com>
References: <1426022224-28793-1-git-send-email-ncardwell@google.com>
	<1426022224-28793-2-git-send-email-ncardwell@google.com>
	<20150311.165214.2047968573920569481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:33118 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbCKWKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 18:10:43 -0400
Received: by qcvx3 with SMTP id x3so14151083qcv.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 15:10:43 -0700 (PDT)
In-Reply-To: <20150311.165214.2047968573920569481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 4:52 PM, David Miller <davem@davemloft.net> wrote:
> From: Neal Cardwell <ncardwell@google.com>
> Date: Tue, 10 Mar 2015 17:17:04 -0400
>
>> Commit 814d488c6126 ("tcp: fix the timid additive increase on stretch
>> ACKs") fixed a bug where tcp_cong_avoid_ai() would either credit a
>> connection with an increase of snd_cwnd_cnt, or increase snd_cwnd, but
>> not both, resulting in cwnd increasing by 1 packet on at most every
>> alternate invocation of tcp_cong_avoid_ai().
>>
>> Although the commit correctly implemented the CUBIC algorithm, which
>> can increase cwnd by as much as 1 packet per 1 packet ACKed (2x per
>> RTT), in practice that could be too aggressive: in tests on network
>> paths with small buffers, YouTube server retransmission rates nearly
>> doubled.
>>
>> This commit restores CUBIC to a maximum cwnd growth rate of 1 packet
>> per 2 packets ACKed (1.5x per RTT). In YouTube tests this restored
>> retransmit rates to low levels.
>>
>> Testing: This patch has been tested in datacenter netperf transfers
>> and live youtube.com and google.com servers.
>>
>> Fixes: 9cd981dcf174 ("tcp: fix stretch ACK bugs in CUBIC")
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> Applied.

Thanks!

My sense is that both of these fixes are appropriate for the stable
queue, since they fix serious packet loss issues that folks running
3.19.x will run into:

d578e18 tcp: restore 1.5x per RTT limit to CUBIC cwnd growth in
congestion avoidance
9949afa tcp: fix tcp_cong_avoid_ai() credit accumulation bug with decreases in w

neal
