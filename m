From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: Fixed M-Flag in last fragment
Date: Sat, 28 Jun 2003 19:12:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030628.191212.43739794.yoshfuji@linux-ipv6.org>
References: <20030628.191013.105714999.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030628.191013.105714999.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030628.191013.105714999.yoshfuji@linux-ipv6.org> (at Sat, 28 Jun 2003 19:10:13 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> Hello.
> 
> M-Flag was set on last fragment.

Oops, here's the patch.
Thanks.

Index: linux-2.5/net/ipv6/ip6_output.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ip6_output.c,v
retrieving revision 1.30
diff -u -r1.30 ip6_output.c
--- linux-2.5/net/ipv6/ip6_output.c	24 Jun 2003 21:56:18 -0000	1.30
+++ linux-2.5/net/ipv6/ip6_output.c	28 Jun 2003 08:52:47 -0000
@@ -1004,9 +1004,7 @@
 				offset += skb->len - hlen - sizeof(struct frag_hdr);
 				fh->nexthdr = nexthdr;
 				fh->reserved = 0;
-				if (frag->next != NULL)
-					offset |= 0x0001;
-				fh->frag_off = htons(offset);
+				fh->frag_off = htons(offset | (frag->next != NULL ? 0x0001 : 0));
 				fh->identification = frag_id;
 				frag->nh.ipv6h->payload_len = htons(frag->len - sizeof(struct ipv6hdr));
 				ip6_copy_metadata(frag, skb);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
