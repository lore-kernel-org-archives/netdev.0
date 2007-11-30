From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH]: fix lro_gen_skb() alignment
Date: Fri, 30 Nov 2007 13:35:16 -0500
Message-ID: <475057E4.3000909@myri.com>
References: <E1Iy2ey-0005eY-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000004090007080503060901"
Cc: davem@davemloft.net, ossthema@de.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1855 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761214AbXK3SgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 13:36:06 -0500
In-Reply-To: <E1Iy2ey-0005eY-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000004090007080503060901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> Andrew Gallatin <gallatin@myri.com> wrote:
>> diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
>> index ac3b1d3..91e9371 100644
>> --- a/net/ipv4/inet_lro.c
>> +++ b/net/ipv4/inet_lro.c
>> @@ -401,10 +401,11 @@ static struct sk_buff *lro_gen_skb(struc
>>        int data_len = len;
>>        int hdr_len = min(len, hlen);
>>
>> -       skb = netdev_alloc_skb(lro_mgr->dev, hlen);
>> +       skb = netdev_alloc_skb(lro_mgr->dev, hlen + NET_IP_ALIGN);
> 
> NET_IP_ALIGN should only be used if you're DMAing into the skb head.
> Otherwise you should say 2.  It would be nice to have another macro
> for that I suppose.

It is certainly simple enough to say 2.  Thank you for pointing
this out.  I have attached a patch to do that..

Signed off by: Andrew Gallatin <gallatin@myri.com>

Drew

--------------000004090007080503060901
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="lro_align_2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lro_align_2.diff"

diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index ac3b1d3..35b816e 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -401,10 +401,11 @@ static struct sk_buff *lro_gen_skb(struc
 	int data_len = len;
 	int hdr_len = min(len, hlen);
 
-	skb = netdev_alloc_skb(lro_mgr->dev, hlen);
+	skb = netdev_alloc_skb(lro_mgr->dev, hlen + 2);
 	if (!skb)
 		return NULL;
 
+	skb_reserve(skb, 2);
 	skb->len = len;
 	skb->data_len = len - hdr_len;
 	skb->truesize += true_size;

--------------000004090007080503060901--
