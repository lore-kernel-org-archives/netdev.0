From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [ofa-general] Re: [PATCH 02/11] IB/ipoib: Notify the world before
	doing unregister
Date: Mon, 17 Sep 2007 16:23:58 -0700
Message-ID: <18593.1190071438@death>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
	<11898132322950-git-send-email-fubar@us.ibm.com>
	<1189813234208-git-send-email-fubar@us.ibm.com>
	<adatzptkjyk.fsf@cisco.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, jgarzik@pobox.com,
	davem@davemloft.net
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-reply-to: <adatzptkjyk.fsf@cisco.com> 
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

Roland Dreier <rdreier@cisco.com> wrote:

>Actually, thinking about this some more... would it be cleaner to more
>the knowledge about bonding out of the ipoib driver?  in other words,
>export something similar to
>
> > +static int ipoib_slave_detach(struct net_device *dev)
> > +{
> > +	int ret = 0;
> > +	if (dev->flags & IFF_SLAVE) {
> > +		dev->priv_flags |= IFF_SLAVE_DETACH;
> > +		rtnl_lock();
> > +		ret = call_netdevice_notifiers(NETDEV_CHANGE, dev);
> > +		rtnl_unlock();
> > +	}
> > +	return ret;
> > +}
>
>for drivers to use, rather than putting use of IFF_SLAVE and
>IFF_SLAVE_DETACH outside of the bonding driver.

	Conceptually, I see your point and I'm ok with doing it either
way.  My only question is, would this change would make the ipoib module
dependent upon having the bonding module loaded (to resolve all of the
symbols)?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
