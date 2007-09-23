From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH V5 2/11] IB/ipoib: Notify the world
	before	doing unregister
Date: Sun, 23 Sep 2007 09:34:46 -0700
Message-ID: <adar6kpwdax.fsf@cisco.com>
References: <46F27692.3070404@voltaire.com> <46F2784C.9070806@voltaire.com>
	<adaabrhgvfa.fsf@cisco.com> <46F61BF6.3000203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Moni Shoua <monisonlists@gmail.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46F61BF6.3000203@gmail.com> (Moni Shoua's message of "Sun,
	23 Sep 2007 09:55:34 +0200")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > The action in bonding to a detach of slave is to unregister the master (see patch 10).
 > This can't be done from the context of unregister_netdevice itself (it is protected by rtnl_lock).

I'm confused.  Your patch has:

 > +		ipoib_slave_detach(cpriv->dev);
 >  		unregister_netdev(cpriv->dev);

And ipoib_slave_detach() is:

 > +static inline void ipoib_slave_detach(struct net_device *dev)
 > +{
 > +	rtnl_lock();
 > +	netdev_slave_detach(dev);
 > +	rtnl_unlock();
 > +}

so you are calling netdev_slave_detach() with the rtnl lock held.
Why can't you make the same call from the start of unregister_netdevice()?

Anyway, if the rtnl lock is a problem, can you just add the call to
netdev_slave_detach() to unregister_netdev() before it takes the rtnl lock?

 - R.
