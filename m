From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip6tables: accept of IPv6 transport esp packages not possible
 - no rule matches
Date: Sat, 25 Dec 2004 16:46:23 +0100
Message-ID: <41CD8B4F.6010402@trash.net>
References: <019064D0423CE6C823CBF476@t1mobil.muc.aerasec.de>
	<5F6ACA5CEF52DBFBF11FBF94@t1mobil.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070905080408060602080109"
Cc: Maillist netdev <netdev@oss.sgi.com>,
	Netfilter development mailing list <netfilter-devel@lists.netfilter.org>,
	USAGI core <usagi-core@linux-ipv6.org>, Harald Welte <laforge@gnumonks.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Peter Bieringer <pb@bieringer.de>
In-Reply-To: <5F6ACA5CEF52DBFBF11FBF94@t1mobil.muc.aerasec.de>
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
--------------070905080408060602080109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Peter Bieringer wrote:
> Looks like there is something going wrong in the protocol matching 
> algorithm in netfilter6.

Does this patch fix the problem ?

Regards
Patrick

--------------070905080408060602080109
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/ipv6/netfilter/ip6_tables.c 1.34 vs edited =====
--- 1.34/net/ipv6/netfilter/ip6_tables.c	2004-11-10 01:44:26 +01:00
+++ edited/net/ipv6/netfilter/ip6_tables.c	2004-12-25 16:42:21 +01:00
@@ -234,7 +234,7 @@
 			 * we will change the return 0 to 1*/
 			if ((currenthdr == IPPROTO_NONE) || 
 				(currenthdr == IPPROTO_ESP))
-				return 0;
+				break;
 
 			hp = skb_header_pointer(skb, ptr, sizeof(_hdr), &_hdr);
 			BUG_ON(hp == NULL);

--------------070905080408060602080109--
