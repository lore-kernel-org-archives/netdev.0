From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v5 01/14] vlan: wrap hw-acceleration
 calls in separate functions.
Date: Fri, 11 Jan 2013 09:20:04 -0800
Message-ID: <20130111092004.2d55ae65@nehalam.linuxnetplumber.net>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
	<1357751882-8619-2-git-send-email-vyasevic@redhat.com>
	<20130110102525.2ff40c12@nehalam.linuxnetplumber.net>
	<50EF0B76.2040503@redhat.com>
	<20130110140749.153023fa@nehalam.linuxnetplumber.net>
	<50EF660B.2090500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	davem@davemloft.net
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <50EF660B.2090500@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

What I think is the least intrusive and allows for maximum flexibility
is having the VLAN bridge filtering depend on VLAN support (CONFIG_VLAN_8021Q).
There already is drivers that depend on that value to enable filtering.

And make the support of VLAN filtering in the bridge conditional like
IGMP snooping is optional

--- a/net/bridge/Kconfig
+++ b/net/bridge/Kconfig
@@ -46,3 +46,17 @@ config BRIDGE_IGMP_SNOOPING
          Say N to exclude this support and reduce the binary size.
 
          If unsure, say Y.
+
+config BRIDGE_VLAN_FILTERING
+       bool "VLAN filtering"
+       depends on BRIDGE
+       depends on VLAN_8021Q
+       default n
+       ---help---
+         If you say Y here, then the Ethernet bridge will be able to
+        selectively filter traffic based on VLAN tag.
+
+        Say N to exclude this support and reduce the binary size.
+
+        If unsure, say Y.
