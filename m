From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/3] net: Fix drivers advertising HW_CSUM
 feature to use csum_start
Date: Wed, 15 Dec 2010 10:25:36 -0800
Message-ID: <20101215102536.6430274b@nehalam>
References: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
	<aa9d85fa4961e87c38aec922913cbc95465fc082.1292372504.git.mirq-linux@rere.qmqm.pl>
	<20101214190727.0ed1a925@nehalam>
	<20101215181655.GA29962@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: Roopa Prabhu <roprabhu@cisco.com>, Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Vasanthy, Jie Yang <Jie.Yang@atheros.com>, Eric,
	Kolluri <vkolluri@cisco.com>, "VMware,
	Inc." <pv-drivers@vmware.com>, Brice Goglin <brice@myri.com>, H,
	Andrew Gallatin <gallatin@myri.com>,
	Joe Perches <joe@perches.com>, David Wang <dwang2@cisco.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sweeten <hsweeten@visionengravers.com>
To: =?iso-8859-2?B?TWljaGGzIE1pcm9zs2F3?= <mirq-linux@rere.qmqm.pl>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20101215181655.GA29962@rere.qmqm.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2010 19:16:55 +0100
Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:

> On Tue, Dec 14, 2010 at 07:07:27PM -0800, Stephen Hemminger wrote:
> > On Wed, 15 Dec 2010 02:24:08 +0100 (CET)
> > Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > > Some drivers are using skb_transport_offset(skb) instead of skb->csum=
_start
> > > for NETIF_F_HW_CSUM offload.  This does not matter now, but if someone
> > > implements checksumming of encapsulated packets then this will break =
silently.
> > > =

> > > TSO output paths are left as they are, since they are for IP+TCP only
> > > (might be worth converting though).
> > > =

> > > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > Which if any of these drivers did you test on real hardware?
> =

> I'm running it on skge, with additional patch that changes it to use
> NETIF_F_HW_CSUM instead of NETIF_F_IP_CSUM. BTW, why it is not advertising
> full HW checksum in vanilla kernel? Are there any known hardware bugs in =
there?
> =

> Best Regards,
> Micha=B3 Miros=B3aw

The driver was written from vendor sk98lin driver and that driver
only did IP checksum, therefore I did not trust the hardware.
The chipset is old, and not used in new designs, no documentation
is up to date (and I didn't have any).

Please don't enable non-IPv4 checksum offload on this hardware, there
is too big a risk of it not working on all hardware.

-- =


---------------------------------------------------------------------------=
---
Lotusphere 2011
Register now for Lotusphere 2011 and learn how
to connect the dots, take your collaborative environment
to the next level, and enter the era of Social Business.
http://p.sf.net/sfu/lotusphere-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
