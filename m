From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH][Resend 2][BUILD FAILURE 04/04] Next June 04:PPC64
 randconfig [drivers/net/ucc_geth.o]
Date: Wed, 17 Jun 2009 23:34:52 +1000
Message-ID: <20090617233452.03ac78d5.sfr@canb.auug.org.au>
References: <20090611033705.20842.75501.sendpatchset@subratamodak.linux.ibm.com>
	<1245048719.5239.10.camel@subratamodak.linux.ibm.com>
	<1245243097.4870.3.camel@subratamodak.linux.ibm.com>
	<6E26D0A1-0FE5-4179-9DA8-FDF0E3D417DA@kernel.crashing.org>
	<20090617232341.c4543ff2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: subrata@linux.vnet.ibm.com, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>, Nathan Lynch <ntl@pobox.com>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Tony Breeds <tony@bakeyournoodle.com>, michael@ellerman.id.au,
	Haiying Wang <Haiying.Wang@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090617232341.c4543ff2.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Jun 2009 23:23:41 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Hi Kumar,
> 
> On Wed, 17 Jun 2009 08:07:47 -0500 Kumar Gala <galak@kernel.crashing.org> wrote:
> >
> > 
> > I'm confused by the proposed fix as we already have *mdio & *ph  
> > defined in this function:
> 
> Which tree are you looking at?  Linus' tree, and linux-next, do not have
> those local variables ...

Hmmm, commit 0b9da337dca972e7a4144e298ec3adb8f244d4a4 ("net: Rework
ucc_geth driver to use of_mdio infrastructure") removed the locals along
with their usages, then commit 047584ce94108012288554a5f84585d792cc7f8f
("net/ucc_geth: Add SGMII support for UEC GETH driver") added more uses
without adding the variables back.

Here is the patch again:

From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: [PATCH] Fix build error in ucc_geth.c

Fix the following build error:

drivers/net/ucc_geth.c: In function bucc_geth_probeb:
drivers/net/ucc_geth.c:3822: error: 'ph' undeclared (first use in this function)
drivers/net/ucc_geth.c:3822: error: (Each undeclared identifier is reported only once
drivers/net/ucc_geth.c:3822: error: for each function it appears in.)
drivers/net/ucc_geth.c:3832: error: 'mdio' undeclared (first use in this function)
make[2]: *** [drivers/net/ucc_geth.o] Error 1

Signed-off-by: Subrata Modak <subrata@linux.vnet.ibm.com>

--- linux-2.6.30-rc8/drivers/net/ucc_geth.c.orig	2009-06-10 11:58:39.000000000 -0500
+++ linux-2.6.30-rc8/drivers/net/ucc_geth.c	2009-06-10 22:28:13.000000000 -0500
@@ -3595,6 +3595,8 @@ static const struct net_device_ops ucc_g
 
 static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *match)
 {
+	struct device_node *mdio;
+	const phandle *ph;
 	struct device *device = &ofdev->dev;
 	struct device_node *np = ofdev->node;
 	struct net_device *dev = NULL;


-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
