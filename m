From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER 00/10]: Netfilter IPsec support
Date: Sat,  7 Jan 2006 02:09:30 +0100 (MET)
Message-ID: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S. Miller <davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following are the remaining patches for netfilter IPsec support.
They are missing the common-case optimization for inner transport mode
SAs on the input path, but since its just an optimization, I think
it can also be done later. One note: unfortunately I had to increase
skb->cb to make room for two new fields in the IP6CB. Yoshifuji
mentioned he needs more room for mobile IPv6 extensions anyway, so
hopefully this will leave enough room for both. One idea to save some
space again would be to introduce a struct that is a subset of
inet6_skb_parm and only holds the fields needed after the packet is
passed to the upper protocol and use that struct in tcp_skb_cb.
