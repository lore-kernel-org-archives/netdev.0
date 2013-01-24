From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH 1/2] tcp: make tcp_timestamp dependent on tcp_sock
Date: Thu, 24 Jan 2013 11:46:02 +0400
Message-ID: <20130124074602.GD8877@paralelels.com>
References: <1358953314-12979-1-git-send-email-avagin@openvz.org>
 <1358953314-12979-2-git-send-email-avagin@openvz.org>
 <1358958317.12374.814.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: Andrey Vagin <avagin@openvz.org>, <netdev@vger.kernel.org>,
	<criu@openvz.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Dave Jones <davej@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:40677 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab3AXHrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 02:47:04 -0500
Content-Disposition: inline
In-Reply-To: <1358958317.12374.814.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 08:25:17AM -0800, Eric Dumazet wrote:
> > @@ -1142,9 +1145,11 @@ static inline void tcp_openreq_init(struct request_sock *req,
> >  static inline void tcp_synack_rtt_meas(struct sock *sk,
> >  				       struct request_sock *req)
> >  {
> > +	const struct tcp_sock *tp = tcp_sk(sk);
> > +
> >  	if (tcp_rsk(req)->snt_synack)
> >  		tcp_valid_rtt_meas(sk,
> > -		    tcp_time_stamp - tcp_rsk(req)->snt_synack);
> > +		    tcp_time_stamp(tp) - tcp_rsk(req)->snt_synack);
> >  }
> >  
> 
> This first chunk looks not needed.
> 
> Can SYN_RECV sockets be live-migrated ? Probably not.
> 
> Quite frankly I am sure there is an issue for timewait (not real
> sockets).
> 
> Have you really tested this patch, or is it an RFC ?

I set RFC, when I'm not sure, that this idea is right and want to get
opinions and comments before spend a lot of time.

I have tested this patch. I have a virtuall machine, where I test
kernels. SSH is used for accessing this VM. My test dumps an outside
TCP connection, then reboots the VM and restores the TCP connection.
Without this patch the tcp connection are not restored correctly, but
with this patch it works properly.

A timestamp offset is zero by default, so I did not catch any bugs.
I will test my patches more carefully.

Thank you all for the comments and sorry for noise in the ML.

> 
> 
