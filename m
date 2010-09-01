From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers/net/pch_gbe: Cleanup stats use
Date: Tue, 31 Aug 2010 18:38:45 -0700
Message-ID: <1283305125.1797.112.camel@Joe-Laptop>
References: <4C763A67.5040107@dsn.okisemi.com>
	 <4C7D0E7A.5060309@dsn.okisemi.com> <1283271009.1797.28.camel@Joe-Laptop>
	 <1283275514.1797.36.camel@Joe-Laptop> <1283279915.1797.66.camel@Joe-Laptop>
	 <20100831183331.5a6aa508@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Sam Ravnborg <sam@ravnborg.org>,
	LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1151 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754232Ab0IABir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 21:38:47 -0400
In-Reply-To: <20100831183331.5a6aa508@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-31 at 18:33 -0700, Stephen Hemminger wrote:
> On Tue, 31 Aug 2010 11:38:35 -0700
> Joe Perches <joe@perches.com> wrote:
> 
> >  struct pch_gbe_stats {
> > -	signed char stat_string[ETH_GSTRING_LEN];
> > -	int sizeof_stat;
> > -	int stat_offset;
> > +	signed char string[ETH_GSTRING_LEN];
> > +	size_t size;
> > +	size_t offset;
> >  };
> 
> Is this driver really using 'signed char' here?
> Should just be 'char' for a simple string.

You're right.  Probably all the below should just be char.

$ grep -Pn "\bsigned\s+char\b" drivers/net/pch_gbe/*.[ch]
pch_gbe_ethtool.c:34:	signed char string[ETH_GSTRING_LEN];
pch_gbe_param.c:155:	signed char *name;
pch_gbe_param.c:156:	signed char *err;
pch_gbe_param.c:165:			struct pch_gbe_opt_list { int i; signed char *str; } *p;


