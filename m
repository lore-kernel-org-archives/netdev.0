From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: igmp: use IS_ENABLED(CONFIG_IP_MULTICAST) instead of ifdef
Date: Tue, 16 Feb 2016 17:33:18 +0100
Message-ID: <13046365.7R7s0XiHQi@wuerfel>
References: <1455638393-3269483-1-git-send-email-arnd@arndb.de> <56C34A0C.9040207@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C34A0C.9040207@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 16 February 2016 18:10:52 Nikolay Borisov wrote:
> On 02/16/2016 05:59 PM, Arnd Bergmann wrote:
> > @@ -1821,17 +1807,15 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
> >  		if (!err && rv < 0)
> >  			err = rv;
> >  	}
> > -	if (pmc->sfmode == MCAST_EXCLUDE &&
> > +	if (IS_ENABLED(CONFIG_IP_MULTICAST) &&
> > +	    pmc->sfmode == MCAST_EXCLUDE &&
> >  	    pmc->sfcount[MCAST_EXCLUDE] == 0 &&
> >  	    pmc->sfcount[MCAST_INCLUDE]) {
> > -#ifdef CONFIG_IP_MULTICAST
> >  		struct ip_sf_list *psf;
> >  		struct net *net = dev_net(in_dev->dev);
> > -#endif
> >  
> >  		/* filter mode change */
> >  		pmc->sfmode = MCAST_INCLUDE;
> 
> The above line was always executed, whereas now it wouldn't execute
> unless IS_ENABLED passes.

This was not intentional, I've sent a v2 patch to fix it up now, and
tried to simplify it a little further, making the logic the
same for  ip_mc_del_src and ip_mc_add_src.

> >  /*
> >   * Add multicast source filter list to the interface list
> > @@ -1977,9 +1961,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
> >  	spin_lock_bh(&pmc->lock);
> >  	rcu_read_unlock();
> >  
> > -#ifdef CONFIG_IP_MULTICAST
> >  	sf_markstate(pmc);
> > -#endif
> 
> This would be executed unconditionally, which is contrary to the
> original intention. Dunno if it makes a difference though.

This was intentional, I have changed sf_markstate() to do nothing when
IP_MULTICAST is disabled. However, there was another caller where
I should have done the same thing rather than adding an if().

> Reviewed-by: Nikolay Borisov <kernel@kyup.com>

Thanks!

	Arnd
