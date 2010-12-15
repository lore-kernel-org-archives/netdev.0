From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 3/3] net: Fix drivers advertising HW_CSUM
	feature to	use csum_start
Date: Wed, 15 Dec 2010 19:16:55 +0100
Message-ID: <20101215181655.GA29962@rere.qmqm.pl>
References: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
	<aa9d85fa4961e87c38aec922913cbc95465fc082.1292372504.git.mirq-linux@rere.qmqm.pl>
	<20101214190727.0ed1a925@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: Roopa Prabhu <roprabhu@cisco.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Shreyas Bhatewara <sbhatewara@vmware.com>, Jie Yang <Jie.Yang@atheros.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>, "VMware,
	Inc." <pv-drivers@vmware.com>, Brice Goglin <brice@myri.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Joe Perches <joe@perches.com>, David Wang <dwang2@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	H Hartley Sweeten <hsweeten@visionengravers.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20101214190727.0ed1a925@nehalam>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2010 at 07:07:27PM -0800, Stephen Hemminger wrote:
> On Wed, 15 Dec 2010 02:24:08 +0100 (CET)
> Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl> wrote:
> > Some drivers are using skb_transport_offset(skb) instead of skb->csum_s=
tart
> > for NETIF_F_HW_CSUM offload.  This does not matter now, but if someone
> > implements checksumming of encapsulated packets then this will break si=
lently.
> > =

> > TSO output paths are left as they are, since they are for IP+TCP only
> > (might be worth converting though).
> > =

> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Which if any of these drivers did you test on real hardware?

I'm running it on skge, with additional patch that changes it to use
NETIF_F_HW_CSUM instead of NETIF_F_IP_CSUM. BTW, why it is not advertising
full HW checksum in vanilla kernel? Are there any known hardware bugs in th=
ere?

Best Regards,
Micha=B3 Miros=B3aw

---
lspci:

02:05.0 Ethernet controller: 3Com Corporation 3c940 10/100/1000Base-T [Marv=
ell] (rev 12)
        Subsystem: ASUSTeK Computer Inc. A7V600/P4P800/K8V motherboard
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-=
 Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- =
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 16 bytes
        Interrupt: pin A routed to IRQ 22
        Region 0: Memory at feafc000 (32-bit, non-prefetchable) [size=3D16K]
        Region 1: I/O ports at d800 [size=3D256]
        Capabilities: <access denied>
        Kernel driver in use: skge
        Kernel modules: skge

ethtool -k:

Offload parameters for eth3:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: on
large receive offload: off


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
