From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: xen-netback: convert to hw_features
Date: Tue, 19 Apr 2011 17:25:17 +0200
Message-ID: <20110419152517.GA12388@rere.qmqm.pl>
References: <20110419115612.C4ACA13909@rere.qmqm.pl>
	<1303219073.5997.191.camel@zakaz.uk.xensource.com>
	<20110419133019.GA3973@rere.qmqm.pl>
	<1303220340.5997.197.camel@zakaz.uk.xensource.com>
	<20110419134352.GB4716@rere.qmqm.pl>
	<1303226148.5997.233.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
Content-Disposition: inline
In-Reply-To: <1303226148.5997.233.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2011 at 04:15:48PM +0100, Ian Campbell wrote:
> On Tue, 2011-04-19 at 14:43 +0100, Micha=B3 Miros=B3aw wrote:
> > On Tue, Apr 19, 2011 at 02:39:00PM +0100, Ian Campbell wrote:
> > > On Tue, 2011-04-19 at 14:30 +0100, Micha=B3 Miros=B3aw wrote:
> > > > On Tue, Apr 19, 2011 at 02:17:53PM +0100, Ian Campbell wrote:
> > > > > I fixed it with the following, I also moved the !can_sg MTU cla=
mping
> > > > > into a set_features hook (like we do with netfront). Am I right=
 that
> > > > > this pattern copes with changes to SG via ethtool etc better? I=
 think
> > > > > it's more future proof in any case.
> > > > This looks wrong. Even if SG is turned on, you might get big skbs=
 which
> > > > are linearized. There is a difference in SG capability and SG off=
load
> > > > status and as I see it the capability is what you need to test fo=
r MTU.
> > > So the existing stuff in drivers/net/xen-netfront.c is wrong too?
> > Looks like it. But I don't really know what are the real constraints =
for MTU.
> > What I know is that SG even if turned on needs not be used (and curre=
ntly
> > it's not e.g. if checksum offload is disabled).
> The interesting case is the opposite one, isn't it? IOW if NETIF_F_SG i=
s
> disabled but the frontend/backend agree that they have the capability t=
o
> handle >PAGE_SIZE skbs

Then the driver might get bigger skbs but they won't ever be fragmented.

> In my experience, the normal reason for disabling the NETIF_F_SG offloa=
d
> status is that the underlying capability is somehow buggy, otherwise is
> there any reason to turn it off?

Some features depend on others to function or on some hardware/software s=
tate.
Though in most cases the reason is the one you wrote (capability also inc=
ludes
what driver has implemented).

Best Regards,
Micha=B3 Miros=B3aw
