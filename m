From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch -stable] igbvf: integer wrapping bug setting the mtu
Date: Fri, 13 Sep 2013 11:55:34 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7332@saturn3.aculab.com>
References: <20130913083736.GK19211@elgon.mountain> <AE90C24D6B3A694183C094C60CF0A2F6026B732F@saturn3.aculab.com> <20130913095423.GH19256@mwanda>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>,
	"Bruce Allan" <bruce.w.allan@intel.com>,
	"Carolyn Wyborny" <carolyn.wyborny@intel.com>,
	"Don Skidmore" <donald.c.skidmore@intel.com>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>,
	"Alex Duyck" <alexander.h.duyck@intel.com>,
	"John Ronciak" <john.ronciak@intel.com>,
	"Tushar Dave" <tushar.n.dave@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Mitch Williams" <mitch.a.williams@intel.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: "Dan Carpenter" <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20130913095423.GH19256@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > >  static int igbvf_change_mtu(struct net_device *netdev, int new_mtu)
> > >  {
> > >  	struct igbvf_adapter *adapter = netdev_priv(netdev);
> > > -	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
> > > +	unsigned int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
> > >
> > >  	if ((new_mtu < 68) || (max_frame > MAX_JUMBO_FRAME_SIZE)) {
> > >  		dev_err(&adapter->pdev->dev, "Invalid MTU setting\n");
> >
> > It is safer to check:
> >   	if ((new_mtu < 68) || (new_mtu > MAX_JUMBO_FRAME_SIZE - ETH_HLEN - ETH_FCS_LEN)) {
> >
> 
> I believe my fix is already 100% safe...  Where is the bug in my code?
> 
> Your fix harder to read because of the additional math and because it's
> checking "new_mtu" when we care about "max_frame".

I don't like the window check on two variables.

However if ETH_HLEN and ETH_FCS_LEN are 'int' (not an unsigned type)
and 'new_mtu' is just below MAX_INT then the signed arithmetic
could overflow - generating an indeterminate value.
In which case 'max_frame' might not exceed MAX_JUMBO_FRAME_SIZE.

	David



