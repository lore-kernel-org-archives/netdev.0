From: Komuro <komurojun@nifty.com>
Subject: Re: [NOT VERY SAFE]     [TCP]: Set initial_ssthresh default to zero
 in Cubic and BIC.
Date: Sun, 14 Oct 2007 13:28:51 +0900
Message-ID: <20071014132851.8d6a9de3.komurojun@nifty.com>
References: <20071006132601.f944f461.komurojun@nifty.com>
	<20071014073658.d4352b8c.komurojun@nifty.com>
	<20071014100245.914b784a.komurojun@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@sunset.davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755837AbXJNEaS@vger.kernel.org>
In-Reply-To: <20071014100245.914b784a.komurojun@nifty.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Dear David

>Komuro, every single email I sent to you bounces with "user unknown",
>I bet it is some spam filter or similar that doesn't like the
>fact that I lack reverse DNS.

>From mailing-list-archive,
I can read your email.

Best Regards
Komuro

> Dear David
> 
> Actually, tcp_sk(sk)->snd_ssthresh is not initialized,
> if initial_ssthresh is 0.
> 
> The patch should be
> 
>  static void bictcp_init(struct sock *sk)
>  {
>  	bictcp_reset(inet_csk_ca(sk));
> -	if (initial_ssthresh)
> -		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
> +
> +	tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
>  }
> 
> Best Regards
> Komuro
> 
> > 
> > Dear David
> > 
> > The patch "[TCP]: Set initial_ssthresh default to zero in Cubic and BIC."
> > is not very safe.
> > 
> > With this patch, ftp-transfer stops in my system.
> > (vsftpd-2.0.5-8)
> > 
> > Please revert this patch.
> > 
> > 
> > Best Regards
> > Komuro
> > 
> > >commit 66e1e3b20cbbf99da63e6c1af0fc6d39c2ed099a
> > >Author: David S. Miller <davem@sunset.davemloft.net>
> > >Date:   Wed Jun 13 01:03:53 2007 -0700
> > >
> > >    [TCP]: Set initial_ssthresh default to zero in Cubic and BIC.
> > >    
> > >    Because of the current default of 100, Cubic and BIC perform very
> > >    poorly compared to standard Reno.
> > >    
> > >    In the worst case, this change makes Cubic and BIC as aggressive as
> > >    Reno.  So this change should be very safe.
> > >    
> > >    Signed-off-by: David S. Miller <davem@davemloft.net>
> > >
> > >diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
> > >index 281c9f9..dd9ef65 100644
> > >--- a/net/ipv4/tcp_bic.c
> > >+++ b/net/ipv4/tcp_bic.c
> > >@@ -29,7 +29,7 @@ static int fast_convergence = 1;
> > > static int max_increment = 16;
> > > static int low_window = 14;
> > > static int beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
> > >-static int initial_ssthresh = 100;
> > >+static int initial_ssthresh;
> > > static int smooth_part = 20;
> > > 
> > > module_param(fast_convergence, int, 0644);
> > >diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
> > >index 1422448..ebfaac2 100644
> > >--- a/net/ipv4/tcp_cubic.c
> > >+++ b/net/ipv4/tcp_cubic.c
> > >@@ -29,7 +29,7 @@
> > > static int fast_convergence __read_mostly = 1;
> > > static int max_increment __read_mostly = 16;
> > > static int beta __read_mostly = 819;	/* = 819/1024 (BICTCP_BETA_SCALE) */
> > >-static int initial_ssthresh __read_mostly = 100;
> > >+static int initial_ssthresh __read_mostly;
> > > static int bic_scale __read_mostly = 41;
> > > static int tcp_friendliness __read_mostly = 1;
> > > 
> 
> 
> -- 
> Komuro <komurojun@nifty.com>


-- 
Komuro <komurojun@nifty.com>
