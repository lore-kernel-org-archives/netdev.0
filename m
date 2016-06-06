From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 net] fq_codel: fix NET_XMIT_CN behavior
Date: Mon, 6 Jun 2016 13:42:34 +0200
Message-ID: <20160606114234.GB7827@breakpoint.cc>
References: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160604190301.GA8857@strlen.de>
 <1465070113.2968.18.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVORpFx_xx67gYT_3jXfWAuqkMmR03R9VJv1TrcqH4W8A@mail.gmail.com>
 <1465160087.2968.51.camel@edumazet-glaptop3.roam.corp.google.com>
 <1465160123.2968.52.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXMwT20nhWW4Pd2yy6nkeXkSNdxV9wAEGzGd22PcyePmg@mail.gmail.com>
 <57555536.1090801@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52679 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751631AbcFFLmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 07:42:40 -0400
Content-Disposition: inline
In-Reply-To: <57555536.1090801@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> BTW, returning NET_XMIT_CN could be confusing to tcp;
> it does not mean that the packet that we are getting return
> code for was dropped; it could mean _another_ packet in
> the queue was dropped.

Yes, but we currently conceal NET_XMIT_CN from upper layer (tcp)
via the net_xmit_* macros:

#define net_xmit_eval(e)       ((e) == NET_XMIT_CN ? 0 : (e))
#define net_xmit_errno(e)      ((e) != NET_XMIT_CN ? -ENOBUFS : 0)

Might be worth changing this so tcp reduces cwnd in _CN case too.
