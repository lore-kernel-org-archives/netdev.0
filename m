From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 2/2] fix NF_QUEUE_NR() macro
Date: Thu, 11 Aug 2005 16:31:24 +0200
Message-ID: <200508111631.24785.netdev@axxeo.de>
References: <20050811071320.GB4137@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@gnumonks.org>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
In-Reply-To: <20050811071320.GB4137@rama.de.gnumonks.org>
Content-Disposition: inline
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

Harald Welte wrote:
> Hi Dave, please apply!

What about using a brace more:

>diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
>--- a/include/linux/netfilter.h
>+++ b/include/linux/netfilter.h
>@@ -29,7 +29,7 @@
> #define NF_VERDICT_QMASK 0xffff0000
> #define NF_VERDICT_QBITS 16
> 
>-#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK || NF_QUEUE)
>+#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK | NF_QUEUE)

#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & (NF_VERDICT_QMASK | NF_QUEUE))

I know we are cool and know operator precedence even after 10 beer, but some people
consider it difficult to understand without :-)


Regards

Ingo Oeser
