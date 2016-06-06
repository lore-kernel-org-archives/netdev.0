From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] fq_codel: fix NET_XMIT_CN behavior
Date: Mon, 06 Jun 2016 07:37:25 -0700
Message-ID: <1465223845.2968.61.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160604190301.GA8857@strlen.de>
	 <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpVORpFx_xx67gYT_3jXfWAuqkMmR03R9VJv1TrcqH4W8A@mail.gmail.com>
	 <1465160087.2968.51.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1465160123.2968.52.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpXMwT20nhWW4Pd2yy6nkeXkSNdxV9wAEGzGd22PcyePmg@mail.gmail.com>
	 <57555536.1090801@mojatatu.com> <20160606114234.GB7827@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36684 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108AbcFFOh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 10:37:27 -0400
Received: by mail-pa0-f52.google.com with SMTP id b5so7510378pas.3
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 07:37:27 -0700 (PDT)
In-Reply-To: <20160606114234.GB7827@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-06 at 13:42 +0200, Florian Westphal wrote:
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> > BTW, returning NET_XMIT_CN could be confusing to tcp;
> > it does not mean that the packet that we are getting return
> > code for was dropped; it could mean _another_ packet in
> > the queue was dropped.
> 
> Yes, but we currently conceal NET_XMIT_CN from upper layer (tcp)
> via the net_xmit_* macros:
> 
> #define net_xmit_eval(e)       ((e) == NET_XMIT_CN ? 0 : (e))
> #define net_xmit_errno(e)      ((e) != NET_XMIT_CN ? -ENOBUFS : 0)
> 
> Might be worth changing this so tcp reduces cwnd in _CN case too.

It always had been the case.

tcp_transmit_skb() calls tcp_enter_cwr(), unless someone broke this.
