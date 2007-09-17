From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 02/11] IB/ipoib: Notify the world before
	doing unregister
Date: Mon, 17 Sep 2007 15:25:55 -0700
Message-ID: <adatzptkjyk.fsf@cisco.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
	<11898132322950-git-send-email-fubar@us.ibm.com>
	<1189813234208-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, jgarzik@pobox.com,
	davem@davemloft.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1189813234208-git-send-email-fubar@us.ibm.com> (Jay Vosburgh's
	message of "Fri, 14 Sep 2007 16:40:21 -0700")
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

Actually, thinking about this some more... would it be cleaner to more
the knowledge about bonding out of the ipoib driver?  in other words,
export something similar to

 > +static int ipoib_slave_detach(struct net_device *dev)
 > +{
 > +	int ret = 0;
 > +	if (dev->flags & IFF_SLAVE) {
 > +		dev->priv_flags |= IFF_SLAVE_DETACH;
 > +		rtnl_lock();
 > +		ret = call_netdevice_notifiers(NETDEV_CHANGE, dev);
 > +		rtnl_unlock();
 > +	}
 > +	return ret;
 > +}

for drivers to use, rather than putting use of IFF_SLAVE and
IFF_SLAVE_DETACH outside of the bonding driver.

Also it seems this function could return void, since both call sites
ignore the return value and I don't see anything sensible that IPoIB
could do with the notifier chain return value anyway.

 - R.
