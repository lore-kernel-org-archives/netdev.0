From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2] pktgen: introduce xmit_mode 'rx_inject'
Date: Wed, 06 May 2015 07:35:16 -0700
Message-ID: <554A26A4.1000505@plumgrid.com>
References: <20150505202730.8715.48527.stgit@ivy>	<20150505202959.8715.51882.stgit@ivy>	<5549A772.9060009@gmail.com> <20150506104442.009312cf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38699 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbbEFOfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 10:35:16 -0400
Received: by igbhj9 with SMTP id hj9so17821187igb.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 07:35:16 -0700 (PDT)
In-Reply-To: <20150506104442.009312cf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/15 1:44 AM, Jesper Dangaard Brouer wrote:
>>
>> I was just wondering.  Since M_RX_INJECT is not compatible with
>> clone_skb couldn't the lines added above be moved down into the block
>> below so that you could avoid the additional conditional jump?
>
> Sure, that is possible.  I'll let Alexei answer, as it is his code.
> (And repost if he also thinks so...)

I think this optimization makes sense. Cleans up the code a little too.

 > We could call it "stack_inject" instead? ... to take out the confusing
 > "rx" part of an "transmit/xmit" mode that "receives"

I would vote for: 'mode netif_receive' + 'mode start_xmit'
then if out-of-tree guys would want to upstream their stuff something
like 'mode parse_and_consume' can fit.
