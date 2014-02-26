From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4 2/8] 6lowpan: add
 uncompress header size function
Date: Wed, 26 Feb 2014 19:32:11 +0100
Message-ID: <20140226183209.GA31268@omega>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
	<1393430712-11298-3-git-send-email-alex.aring@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
	<1393439085.407.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1393439085.407.31.camel@joe-AO722>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 26, 2014 at 10:24:45AM -0800, Joe Perches wrote:
> On Wed, 2014-02-26 at 16:10 +0000, David Laight wrote:
> > From: Alexander Aring
> []
> > > diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
> []
> > > +static inline u8 lowpan_addr_mode_size(const u8 addr_mode)
> > > +{
> > > +	switch (addr_mode) {
> > > +	case LOWPAN_IPHC_ADDR_00:
> > > +		return 16;
> > > +	case LOWPAN_IPHC_ADDR_01:
> > > +		return 8;
> > > +	case LOWPAN_IPHC_ADDR_02:
> > > +		return 2;
> > > +	default:
> > > +		return 0;
> > > +	}
> > > +}
> > 
> > The compiler will generate much better code if you index an array instead
> > of using a switch statement.
> 
> Are you sure of that?
> 
> Perhaps the compiler would inline the assignment
> anyway if addr_mode is __builtin_constant_p
> 
> gcc 4.8 here does the same thing with:
> 
> static inline unsigned char f1(unsigned char a)
> {
> 	switch (a) {
> 	case 0: return 16;
> 	case 1: return 8;
> 	case 2: return 2;
> 	default: return 0;
> 	}
> }
> 
> static inline unsigned char f2(unsigned char a)
> {
> 	static const unsigned char rtns[] = { 16, 8, 2, 0 };
> 
> 	return rtns[a & 3];
> }

to make a mask with & 3 is already done, so we don't need that.
I am not sure what I should do now, change or not change? :-)

- Alex

------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
