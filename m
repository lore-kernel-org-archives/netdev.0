From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] Arp announce (for Xen)
Date: Thu, 1 Mar 2007 17:30:30 -0800
Message-ID: <20070301173030.754514ec@freekitty>
References: <20070301232443.195603797@goop.org>
	<20070301232529.648076372@goop.org>
	<20070301164214.4a40bc59@freekitty> <45E7764A.7000100@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, Jeff Garzik <jeff@garzik.org>,
   Ian Pratt <ian.pratt@xensource.com>, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>,
   Andi Kleen <ak@muc.de>, Zachary@smtp.osdl.org,
   virtualization@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <virtualization-bounces@lists.osdl.org>
In-Reply-To: <45E7764A.7000100@goop.org>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.osdl.org>
List-Help: <mailto:virtualization-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=subscribe>
Sender: virtualization-bounces@lists.osdl.org
Errors-To: virtualization-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

What about implementing the unused arp_announce flag on the inetdevice?
Something like the following.  Totally untested...

Looks like it either was there (and got removed) or was planned but
never implemented.

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index e10794d..cefc339 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1089,6 +1089,16 @@ static int inetdev_event(struct notifier
 			}
 		}
 		ip_mc_up(in_dev);
+		/* fallthru */
+
+	case NETDEV_CHANGEADDR:
+		/* Send gratuitous ARP in case of address change or new device */
+		if (IN_DEV_ARP_ANNOUNCE(in_dev))
+			arp_send(ARPOP_REQUEST, ETH_P_ARP,
+				 in_dev->ifa_list->ifa_address, dev,
+				 in_dev->ifa_list->ifa_address, NULL, =

+				 dev->dev_addr, NULL);
+			=

 		break;
 	case NETDEV_DOWN:
 		ip_mc_down(in_dev);
