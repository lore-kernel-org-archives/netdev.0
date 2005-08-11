From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] fix NF_QUEUE_NR() macro
Date: Fri, 12 Aug 2005 07:46:55 +1000
Message-ID: <E1E3Kt5-0006jy-00@gondolin.me.apana.org.au>
References: <200508111631.24785.netdev@axxeo.de>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	laforge@gnumonks.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netdev@axxeo.de (Ingo Oeser)
In-Reply-To: <200508111631.24785.netdev@axxeo.de>
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

Ingo Oeser <netdev@axxeo.de> wrote:
> 
> What about using a brace more:
> 
>>diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
>>--- a/include/linux/netfilter.h
>>+++ b/include/linux/netfilter.h
>>@@ -29,7 +29,7 @@
>> #define NF_VERDICT_QMASK 0xffff0000
>> #define NF_VERDICT_QBITS 16
>> 
>>-#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK || NF_QUEUE)
>>+#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK | NF_QUEUE)
> 
> #define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & (NF_VERDICT_QMASK | NF_QUEUE))

Actually, these two versions are different.  & is higher than | so
Harald's version is actually 

#define NF_QUEUE_NR(x) (((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK) | NF_QUEUE)

Which is it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
