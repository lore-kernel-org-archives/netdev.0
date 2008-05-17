From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 16 May 2008 18:47:39 -0700
Message-ID: <d1c2719f0805161847n2dc84293i1fed2fb0eeda3525@mail.gmail.com>
References: <d1c2719f0805122100u7e550820xff6fcdbc1e538948@mail.gmail.com>
	 <20080512.210202.158182011.davem@davemloft.net>
	 <d1c2719f0805161813kc0dca29y1feaf4d512a959e@mail.gmail.com>
	 <20080516.182933.242150078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:48004 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbYEQBro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 21:47:44 -0400
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id m4H1lfTV010741
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 02:47:41 +0100
Received: from hs-out-0708.google.com (hsbx43.prod.google.com [10.44.100.43])
	by spaceape13.eur.corp.google.com with ESMTP id m4H1ldmQ019623
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 02:47:40 +0100
Received: by hs-out-0708.google.com with SMTP id x43so1002564hsb.3
        for <netdev@vger.kernel.org>; Fri, 16 May 2008 18:47:39 -0700 (PDT)
In-Reply-To: <20080516.182933.242150078.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 6:29 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jerry Chu" <hkchu@google.com>
> Date: Fri, 16 May 2008 18:13:20 -0700
>
>> The host inflight accounting gets screwed up. It looks like
>> pskb_expand_head() called by tcp_tso_acked()->tcp_trim_head() messes
>> up the accounting but I don't know how to fix it (still trying to
>> understand this complex piece of code). There could be other reason
>> as well.
>
> This is just like freeing up a normal SKB, so decrementing the
> in_flight value the appropriate number of packets should do the right
> thing.
>
> tcp_tso_acked() calculates this adjustment for you, in packets_acked.
>

The current pskb_expand_head() code sets skb_shinfo(skb)->in_flight
to NULL to leave the in_flight accounting solely to the other clone to
handle. To calculate in_flight more accurately, it seems to require
splitting the gso_segs and in_flight accounting bewteen the clone and
the skb (with new header), right? Plus any race condition to take care...
Hard to think clearly in a Friday afternoon :-(

Jerry
