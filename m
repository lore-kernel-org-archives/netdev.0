From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: [PATCH net] tcp: do not grow receive window if skb->len < 128
Date: Fri, 27 Dec 2013 15:40:20 +0800
Message-ID: <52BD2EE4.9090801@gmail.com>
References: <2245b9d01fa91d84a8af1e17e1b97f0763f1b792.1388114391.git.panweiping3@gmail.com> <1388124668.12212.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:52991 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab3L0Hkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 02:40:37 -0500
Received: by mail-pd0-f170.google.com with SMTP id g10so8791100pdj.15
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 23:40:36 -0800 (PST)
In-Reply-To: <1388124668.12212.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/27/2013 02:11 PM, Eric Dumazet wrote:
> On Fri, 2013-12-27 at 11:20 +0800, Weiping Pan wrote:
>> Commit 4e4f1fc22681(tcp: properly increase rcv_ssthresh for ofo packets) can
>> grow receive window for out of order packets,
>> but for in order packets, we only call tcp_grow_window() if skb->len >= 128,
>> I think we should add the same condition for out of order packets.
>>
> Why do you think so ? Do you have any experimental data to share ?
Hi, Eric,

No. I am just wondering why you not treat out of order and in order 
packets in the same way,
so I raised this question.
>
> I personally think the basic test in tcp_event_data_recv() is redundant
> with the logic in tcp_grow_window()
I think the original purpose of this test is to reduce the number of 
times of modifying rcv_ssthresh,
then to avoid SWS. And it can help reduce CPU cycles waisted in 
tcp_grow_window()
since it is on the critical path for in order packets.

>
> skb->len < 128 seems a poor test, real factor is skb->len/skb->truesize
> ratio.
Yes.
But since we already have "if (tcp_win_from_space(skb->truesize) <= 
skb->len)" in tcp_grow_window(),
I do not know how to choose another test, or the logic in 
tcp_grow_window() is enough and we can skip that test
in tcp_event_data_recv().
>
> Note: Please always CC a patch author when you mention a commit in
> a changelog.
Ok, I will remember that.

thanks
Weiping Pan
>
> Thanks
>
>
