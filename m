From: Amir Noam <amir.noam@intel.com>
Subject: Re: [Bonding-devel] Re: [PATCH 2/10] [bonding 2.6] fix monitoring functions
Date: Sun, 2 Nov 2003 16:53:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311021653.51194.amir.noam@intel.com>
References: <E6F7D288B394A64585E67497E5126BA601F99145@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, <davem@redhat.com>,
        <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <E6F7D288B394A64585E67497E5126BA601F99145@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 30 October 2003 07:12 pm, Jay Vosburgh wrote:
> >However, the following patch that restores backward
> > compatibility with old ifenslave is still needed for 2.6. I
> > see that it's already been applied by David Miller to 2.4.
>
>         I thought we were dropping the ancient
> (SIOCDEVPRIVATE) backwards compatibility in 2.6.

This patch restores compatibility with old ifenslave versions that
still use the SIOCBONDSETHWADDR command, not necessarily the
SIOCDEVPRIVATE ioctls, so this patch is definitely needed for now. If
we really want to remove backward compatibility in 2.6 we should do
it for all bonding commands and replace them with the new interface.

The problem is, since 2.6 is in effect in code freeze I'm not sure if
we can actually replace the bonding<->ifenslave interface at this time
(as much as I'd like to do it).


Jeff, David,
We haven't heard from either one of you on this issue: We want to drop
support for SIOCDEVPRIVATE in 2.6. As a side effect this will force
users to upgrade their user land tools anyway, so we might as well
use this opportunity to insert the new interface to replace the
current one. (Obviously, it would be preferable for such a change to
take effect before 2.6.0 is made final)

What do you think about making changes to the 2.6 bonding that will
force users to upgrade their ifenslave application? (this new 
ifenslave will be, of course, backward compatible with 2.4 bonding).


For now, however, this patch that restores backward compatibility is
still needed for 2.6. I've noticed I'd sent out the wrong patch
before (on 2003/10/30), so here is the corrected patch.
Sorry for the mix up.

Amir


diff -Naurp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Oct 30 10:38:34 2003
+++ b/drivers/net/bonding/bond_main.c	Sun Nov  2 15:14:21 2003
@@ -3047,6 +3047,10 @@ static int bond_ioctl(struct net_device 
 		case SIOCBONDRELEASE:	
 			ret = bond_release(master_dev, slave_dev); 
 			break;
+		case BOND_SETHWADDR_OLD:
+		case SIOCBONDSETHWADDR:
+			ret = bond_sethwaddr(master_dev, slave_dev);
+			break;
 		case BOND_CHANGE_ACTIVE_OLD:
 		case SIOCBONDCHANGEACTIVE:
 			if (USES_PRIMARY(bond_mode)) {
