From: Amir Noam <amir.noam@intel.com>
Subject: Re: [Bonding-devel] Re: [PATCH 2/10] [bonding 2.6] fix monitoring functions
Date: Thu, 30 Oct 2003 10:56:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310301056.07221.amir.noam@intel.com>
References: <E6F7D288B394A64585E67497E5126BA601F99143@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <davem@redhat.com>, <bonding-devel@lists.sourceforge.net>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <E6F7D288B394A64585E67497E5126BA601F99143@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 29 October 2003 10:01 pm, Jeff Garzik wrote:
> applied to 2.6.  does this need to go into 2.4, too?

As Jay has pointed out this is already in 2.4.

However, the following patch that restores backward compatibility with
old ifenslave is still needed for 2.6. I see that it's already been
applied by David Miller to 2.4.

Amir

diff -Naurp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Oct 30 10:38:34 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Oct 30 10:45:02 2003
@@ -3047,6 +3047,10 @@ static int bond_ioctl(struct net_device 
 		case SIOCBONDRELEASE:	
 			ret = bond_release(master_dev, slave_dev); 
 			break;
+		case BOND_SETHWADDR_OLD:
+		case SIOCBONDSETHWADDR:
+			res = bond_sethwaddr(bond_dev, slave_dev);
+			break;
 		case BOND_CHANGE_ACTIVE_OLD:
 		case SIOCBONDCHANGEACTIVE:
 			if (USES_PRIMARY(bond_mode)) {
