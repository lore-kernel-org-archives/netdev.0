From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Fri, 17 Jun 2016 23:16:51 -0700
Message-ID: <20160618061650.GA17882@u54ee753d2d1854bda401.ant.amazon.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
 <20160616175539.lt7iqjrlixagwfbh@f1.synalogic.ca>
 <1466100412.27155.66.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Poirier <benjamin.poirier@gmail.com>,
	Netanel Belgazal <netanel@annapurnalabs.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com,
	aliguori@amazon.com, antoine.tenart@free-electrons.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466100412.27155.66.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 16, 2016 at 07:06:52PM +0100, Ben Hutchings wrote:
> On Thu, 2016-06-16 at 10:55 -0700, Benjamin Poirier wrote:
> > On 2016/06/13 11:46, Netanel Belgazal wrote:
> [...]
> > > +static ssize_t ena_show_small_copy_len(struct device *dev,
> > > +				=A0=A0=A0=A0=A0=A0=A0struct device_attribute *attr, char *bu=
f)
> > > +{
> > > +	struct ena_adapter *adapter =3D dev_get_drvdata(dev);
> > > +
> > > +	return sprintf(buf, "%d\n", adapter->small_copy_len);
> > > +}
> > > +
> > > +static DEVICE_ATTR(small_copy_len, S_IRUGO | S_IWUSR, ena_show_s=
mall_copy_len,
> > > +		=A0=A0=A0ena_store_small_copy_len);
> >=20
> > This is what many other drivers call (rx_)copybreak. Perhaps it's t=
ime
> > to add it to ethtool as well?
> [...]
>=20
> There is the 'tunable' ethtool API for random parameters like
> rx_copybreak. =A0The ethtool utility doesn't support it yet, though.

So I started implementing proper support for this in ethtool in a
generic way (retrieving the string set, parsing generically, etc), but
it seems that the implementation isn't quite as complete as one would
like. You said [1] that the kernel returns the type of each tunable,
but I don't see this implemented anywhere.

The string set also includes "Unspec", which is of dubious value.

I think that something tunable specific is going to need to be added
apart from ETHTOOL_GSTRINGS to provide ethtool the needed type
information.

--msw

[1] http://thread.gmane.org/gmane.linux.network/367058/focus=3D376701
