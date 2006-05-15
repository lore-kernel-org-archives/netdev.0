From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [PATCH 4/6] myri10ge - First half of the driver
Date: Mon, 15 May 2006 13:02:34 -0400
Message-ID: <1147712555.27252.269.camel@mindpipe>
References: <446259A0.8050504@myri.com>
	 <Pine.GSO.4.44.0605101438410.498-100000@adel.myri.com>
	 <20060510231347.GC25334@electric-eye.fr.zoreil.com>
	 <4463CE88.20301@myri.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viper.oldcity.dca.net ([216.158.38.4]:47835 "HELO
	viper.oldcity.dca.net") by vger.kernel.org with SMTP
	id S964965AbWEORCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 13:02:37 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <4463CE88.20301@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-05-12 at 01:53 +0200, Brice Goglin wrote:
> Francois Romieu wrote:
> >
> >> +	spin_lock(&mgp->cmd_lock);
> >> +	response->result = 0xffffffff;
> >> +	mb();
> >> +	myri10ge_pio_copy((void __iomem *) cmd_addr, buf, sizeof (*buf));
> >> +
> >> +	/* wait up to 2 seconds */
> >>     
> >
> > You must not hold a spinlock for up to 2 seconds.
> >   
> 
> We are working on reducing the delay to about 15ms. It only occurs when
> the driver is loaded or the link brought up.

I think 15ms is quite a long time to hold a spinlock also - most
spinlocks in the kernel are held for less than 500 microseconds.

Can't you use a mutex?

Lee

