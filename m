From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next 0/7] coding style improvements for netfilter
Date: Wed, 14 Oct 2015 12:40:28 +0200
Message-ID: <20151014104028.GA13671@salvia>
References: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444581140-6255-1-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 11, 2015 at 05:32:13PM +0100, Ian Morris wrote:
> This series of patches improves the coding style of the netfilter-ipv6 
> code by addressing some issues detected by checkpatch.
> 
> The changes were previously submitted as part of a larger monolithic 
> patch but on advice from Pablo, these are being re-sent in smaller, 
> more structured batches.

Applied with minor changes. Thanks.

--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -117,7 +117,7 @@ ip6_packet_match(const struct sk_buff *skb,
        if (FWINV(ret != 0, IP6T_INV_VIA_IN)) {
                dprintf("VIA in mismatch (%s vs %s).%s\n",
                        indev, ip6info->iniface,
-                       ip6info->invflags&IP6T_INV_VIA_IN ?" (INV)":"");
+                       ip6info->invflags&IP6T_INV_VIA_IN ? " (INV)" :
"");
                return false;
        }


I have updated this to:

+                       ip6info->invflags & IP6T_INV_VIA_IN ? " (INV)" :
                                         ^ ^

checkpatch was complaining, and given that we were already updating
this line...

@@ -151,7 +151,7 @@ ip6_packet_match(const struct sk_buff *skb,
                                ip6info->proto);

                if (ip6info->proto == protohdr) {
-                       if(ip6info->invflags & IP6T_INV_PROTO) {
+                       if (ip6info->invflags & IP6T_INV_PROTO) {
                                return false;
                        }
                        return true;

Removed the unnecessary brackets for single statement in the if
branch above. It just added one extra line removal to the patch.
