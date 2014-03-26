From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/7] atm: replace del_timer by del_timer_sync
Date: Wed, 26 Mar 2014 23:02:36 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403262301171.31401@ionos.tec.linutronix.de>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>  <1395869625-15209-3-git-send-email-Julia.Lawall@lip6.fr> <1395871015.12610.254.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395871015.12610.254.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Mar 2014, Eric Dumazet wrote:
> On Wed, 2014-03-26 at 22:33 +0100, Julia Lawall wrote:
> > From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> > 
> > diff --git a/net/atm/mpc.c b/net/atm/mpc.c
> > index b71ff6b..91dc58f 100644
> > --- a/net/atm/mpc.c
> > +++ b/net/atm/mpc.c
> > @@ -1492,7 +1492,7 @@ static void __exit atm_mpoa_cleanup(void)
> >  
> >  	mpc_proc_clean();
> >  
> > -	del_timer(&mpc_timer);
> > +	del_timer_sync(&mpc_timer);
> >  	unregister_netdevice_notifier(&mpoa_notifier);
> >  	deregister_atm_ioctl(&atm_ioctl_ops);
> >  
> 
> It seems this timer rearms itself, so this patch wont be enough I fear.

That's why you need del_timer_sync() it waits for the timer handler to
complete and then removes it.

Thanks,

	tglx
