From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: bug fix in proportional rate reduction.
Date: Thu, 23 May 2013 00:10:31 -0700 (PDT)
Message-ID: <20130523.001031.1071247701270523473.davem@davemloft.net>
References: <1369095724-17745-1-git-send-email-nanditad@google.com>
	<1369185127-27255-1-git-send-email-nanditad@google.com>
	<CAK6E8=fKZOFPn1vLxYpMJYhdovodAE8ngbA8LYj7ynOeiGxbjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, edumazet@google.com,
	ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab3EWHKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 03:10:32 -0400
In-Reply-To: <CAK6E8=fKZOFPn1vLxYpMJYhdovodAE8ngbA8LYj7ynOeiGxbjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue, 21 May 2013 18:27:09 -0700

> On Tue, May 21, 2013 at 6:12 PM, Nandita Dukkipati <nanditad@google.com> wrote:
>> This patch is a fix for a bug triggering newly_acked_sacked < 0
>> in tcp_ack(.).
>>
>> The bug is triggered by sacked_out decreasing relative to prior_sacked,
>> but packets_out remaining the same as pior_packets. This is because the
>> snapshot of prior_packets is taken after tcp_sacktag_write_queue() while
>> prior_sacked is captured before tcp_sacktag_write_queue(). The problem
>> is: tcp_sacktag_write_queue (tcp_match_skb_to_sack() -> tcp_fragment)
>> adjusts the pcount for packets_out and sacked_out (MSS change or other
>> reason). As a result, this delta in pcount is reflected in
>> (prior_sacked - sacked_out) but not in (prior_packets - packets_out).
>>
>> This patch does the following:
>> 1) initializes prior_packets at the start of tcp_ack() so as to
>> capture the delta in packets_out created by tcp_fragment.
>> 2) introduces a new "previous_packets_out" variable that snapshots
>> packets_out right before tcp_clean_rtx_queue, so pkts_acked can be
>> correctly computed as before.
>> 3) Computes pkts_acked using previous_packets_out, and computes
>> newly_acked_sacked using prior_packets.
>>
>> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>

Applied, and queued up for -stable, thanks.
