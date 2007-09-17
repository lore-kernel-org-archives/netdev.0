From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 03/11] IB/ipoib: Bound the net device to
	the ipoib_neigh structue
Date: Mon, 17 Sep 2007 15:23:58 -0700
Message-ID: <aday7f5kk1t.fsf@cisco.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
	<11898132322950-git-send-email-fubar@us.ibm.com>
	<1189813234208-git-send-email-fubar@us.ibm.com>
	<11898132352341-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, jgarzik@pobox.com,
	davem@davemloft.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <11898132352341-git-send-email-fubar@us.ibm.com> (Jay Vosburgh's
	message of "Fri, 14 Sep 2007 16:40:22 -0700")
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

Overall idea looks good... one comment:

 > +	if (n->dev->flags & IFF_MASTER) {
 > +		/* n->dev is not an IPoIB device and we have
 > +			to take priv from elsewhere */
 > +		neigh = *to_ipoib_neigh(n);
 > +		if (neigh) {
 > +			priv = netdev_priv(neigh->dev);
 > +			ipoib_dbg(priv, "neigh_destructor for bonding device: %s\n",
 > +				  n->dev->name);
 > +		} else
 > +			return;
 > +	}

seems like it would be cleaner not to worry about bonding here and
just use neigh->dev all the time rather than having two ways to look
up the device.
