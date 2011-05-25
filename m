From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] timers: consider slack value in mod_timer()
Date: Wed, 25 May 2011 12:57:28 +0200 (CEST)
Message-ID: <alpine.LFD.2.02.1105251256270.3078@ionos>
References: <20110521105828.GA29442@Chamillionaire.breakpoint.cc> <BANLkTinGZ0L4oQkBYo9H=R==X5Z+efjRaQ@mail.gmail.com> <20110524121343.GA17312@Chamillionaire.breakpoint.cc> <BANLkTikNSa9otE_cFKRcThUZ5ZCtE7Kyxw@mail.gmail.com>
 <alpine.LFD.2.02.1105251126590.3078@ionos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	LKML <linux-kernel@vger.kernel.org>,
	Arjan van de Ven <arjan@infradead.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Yong Zhang <yong.zhang0@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.02.1105251126590.3078@ionos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 May 2011, Thomas Gleixner wrote:
> On Wed, 25 May 2011, Yong Zhang wrote:
>  	} else {
> -		unsigned long now = jiffies;
> +		long delta = expires - jiffies;
> +
> +		if (delta < 256)
> +			return expires;
>  
> -		/* No slack, if already expired else auto slack 0.4% */
> -		if (time_after(expires, now))
> -			expires_limit = expires + (expires - now)/256;
> +		expires_limit = expires + (expires - now)/256;

That should be

+		expires_limit = expires + delta / 256;

of course.
