From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPv4 IPComp
Date: Thu, 8 May 2003 10:53:55 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0305081052060.22346-100000@excalibur.intercode.com.au>
References: <87znlymypm.wl@karaba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <usagi-core@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitsuru KANDA / =?ISO-2022-JP?B?GyRCP0BFRBsoQiAbJEI9PBsoQg==?= <mk@linux-ipv6.org>
In-Reply-To: <87znlymypm.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 May 2003, Mitsuru KANDA / [ISO-2022-JP] 神田 充 wrote:

> 
> Hello,
> 
> In ipcomp_input():
> 
> The original IP header(iph) is stored(copied) in tmp_iph.
> 
> But after skb_pull(), tmp_iph is copied back to 
> same place where the original IP header exists in skb->nh.raw.
> 
> I believe the attached diff is to fix it for correct behavior 
> which you intend.
> 
> Could you check it?

This looks correct.

Dave, please apply.


- James
-- 
James Morris
<jmorris@intercode.com.au>


--- bk.pending/net/ipv4/ipcomp.c	Mon May  5 15:12:29 2003
+++ bk.w1/net/ipv4/ipcomp.c	Thu May  8 09:59:01 2003
@@ -94,7 +94,9 @@
 	memcpy(&tmp_iph, iph, iph->ihl * 4);
 	nexthdr = *(u8 *)skb->data;
 	skb_pull(skb, sizeof(struct ipcomp_hdr));
+	skb->nh.raw += sizeof(struct ipcomp_hdr);
 	memcpy(skb->nh.raw, &tmp_iph, tmp_iph.iph.ihl * 4);
+	iph = skb->nh.iph;
 	iph->tot_len = htons(ntohs(iph->tot_len) - sizeof(struct ipcomp_hdr));
 	iph->protocol = nexthdr;
 	skb->h.raw = skb->data;
