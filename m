From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 net-next 4/7] tcp: Make use of MSG_EOR flag in
 tcp_sendmsg
Date: Mon, 18 Apr 2016 20:25:39 -0700
Message-ID: <1461036339.10638.147.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
	 <1461019569-3037369-5-git-send-email-kafai@fb.com>
	 <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160418234202.GA27948@kafai-mba.local>
	 <1461024417.10638.141.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160419022704.GB35817@dreloong-mbp.local.DHCP.thefacebook.com>
	 <1461034241.10638.145.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160419031811.GA36188@ashokk-mba.local.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35454 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbcDSDZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 23:25:42 -0400
Received: by mail-pa0-f46.google.com with SMTP id fs9so1825160pac.2
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 20:25:42 -0700 (PDT)
In-Reply-To: <20160419031811.GA36188@ashokk-mba.local.DHCP.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 20:18 -0700, Martin KaFai Lau wrote:
> On Mon, Apr 18, 2016 at 07:50:41PM -0700, Eric Dumazet wrote:
> > I believe it is slightly wrong (to do the goto new_segment if there is
> > no data to send)
> Aha. Thanks for pointing it out.
> 
> >
> > I would instead use this fast path, doing the test _when_ we already
> > have an skb to test for.
> The v1 was doing a check in the loop but the feedback was, instead
> of doing this unlikely(test) repeatedly in the loop, do it before
> entering the loop and do a goto new_segment if needed.
> 
> I agree that doing it in the loop is easier to follow/read
> and checking TCP_SKB_CB(skb)->eor is cheaper than my v1.
> I will respin with your suggestion.

I do not remember the suggestion. It is better to do the test in the
loop, as you could have multiple threads doing a sendmsg() on the same
socket, and eventually sleeping in sk_stream_wait_memory()

A bit convoluted, but who knows what can be done by some applications ;)
