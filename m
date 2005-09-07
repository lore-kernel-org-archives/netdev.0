From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Wed, 07 Sep 2005 23:42:01 +0200
Message-ID: <431F5EA9.8020601@trash.net>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net> <20050907213413.GA8222@schmorp.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040607060909020204010602"
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Marc Lehmann <schmorp@schmorp.de>
In-Reply-To: <20050907213413.GA8222@schmorp.de>
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

This is a multi-part message in MIME format.
--------------040607060909020204010602
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Marc Lehmann wrote:
> On Wed, Sep 07, 2005 at 02:39:20PM +0200, Patrick McHardy <kaber@trash.net> wrote:
> 
>>Please try if loading the ipt_LOG module and executing
>>"echo 255 > /proc/sys/net/ipv4/netfilter/ip_conntrack_log_invalid"
>>gives more information
> 
> Some more messages I get when logging is enabled:
> 
> printk: 1286 messages suppressed.
> ip_ct_tcp: invalid state IN= OUT= SRC=84.56.231.206 DST=xxx.xxx.xxx.xxx LEN=52 TOS=0x00 PREC=0x00 TTL=64 ID=3260 DF PROTO=TCP SPT=41535 DPT=119 SEQ=3475818900 ACK=1819416201 WINDOW=12198 RES=0x00 ACK URGP=0 OPT (0101080A00F5DE260917B744) UID=0 
> printk: 1166 messages suppressed.

This doesn't tell much since we don't know what happend to the
connection before. You can disable message surpressing by echoing
0 to /proc/sys/net/core/message_cost. I had a beer too much for
serious debugging, just to give some hints, does this patch make
the problem go away?


--------------040607060909020204010602
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -843,7 +843,6 @@ static int tcp_error(struct sk_buff *skb
 		if (LOG_INVALID(IPPROTO_TCP))
 			nf_log_packet(PF_INET, 0, skb, NULL, NULL, NULL,
 				  "ip_ct_tcp: bad TCP checksum ");
-		return -NF_ACCEPT;
 	}
 
 	/* Check TCP flags. */

--------------040607060909020204010602--
