From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Tue, 8 Jan 2008 12:48:30 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801081228010.12911@kivilampi-30.cs.helsinki.fi>
References: <20080108020529.GC16156@one.firstfloor.org>
 <20080107.193700.159646842.davem@davemloft.net> <20080108050007.GA25338@one.firstfloor.org>
 <20080107.211018.160153013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, herbert@gondor.apana.org.au,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, acme@redhat.com,
	paul.moore@hp.com, latten@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34585 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758799AbYAHKsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 05:48:35 -0500
In-Reply-To: <20080107.211018.160153013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jan 2008, David Miller wrote:

> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 8 Jan 2008 06:00:07 +0100
> 
> > On Mon, Jan 07, 2008 at 07:37:00PM -0800, David Miller wrote:
> > > The vast majority of them are one, two, and three liners.
> > 
> > % awk '  { line++ } ; /^{/ { total++; start = line } ; /^}/ { len=line-start-3; if (len > 4) l++; if (len >= 10) k++; } ; END { print total, l, l/total, k, k/total }' < include/net/tcp.h
> > 68 28 0.411765 20 0.294118
> > 
> > 41% are over 4 lines, 29% are >= 10 lines.
> 
> Take out the comments and whitespace lines, your script is
> too simplistic.

He should also remove these, which involve just syntactic casting to 
please the compiler:

	struct tcp_sock *tp = tcp_sk(sk);
	struct inet_connection_sock *icsk = inet_csk(sk);

...and maybe some other similar ones. I'm sure that's going to make his 
statistics even more questionable as is because we need tp all around.

But about his concerns, I spend couple of minutes in looking to it by 
hand. These are likely to be a win:
	tcp_set_state
	tcp_prequeue 
	tcp_prequeue_init
	tcp_openreq_init

...about rest I'm very unsure but there are some that probably are a 
minor win as well.

tcp_dec_quickack_mode has only a single caller anyway so I'd doubt that 
it's going to be significant, I thought moving it to .c earlier but 
haven't just done that yet :-).


-- 
 i.
