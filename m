From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH v3 2/2] netfilter: Create revision 2 of xt_hashlimit to
 support higher pps rates
Date: Thu, 22 Sep 2016 18:53:50 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1609221850530.27197@nerf40.vanv.qr>
References: <20160922164344.GB20423@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
        johunt@akamai.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        pai.vishwain@gmail.com
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160922164344.GB20423@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2016-09-22 18:43, Vishwanath Pai wrote:
>+struct hashlimit_cfg2 {
>+	__u32 mode;	  /* bitmask of XT_HASHLIMIT_HASH_* */
>+	__u64 avg;    /* Average secs between packets * scale */
>+	__u64 burst;  /* Period multiplier for upper limit. */

This would have different sizes between i386 and x86_64,
necessiting additional compat functions. It should be padded
or reordered instead.

>+
>+	/* user specified */
>+	__u32 size;		/* how many buckets */
>+	__u32 max;		/* max number of entries */
>+	__u32 gc_interval;	/* gc interval */
>+	__u32 expire;	/* when do entries expire? */
>+
>+	__u8 srcmask, dstmask;
>+};
>+
>+struct xt_hashlimit_mtinfo2 {
>+	char name[NAME_MAX];
>+	struct hashlimit_cfg2 cfg;
>+
>+	/* Used internally by the kernel */
>+	struct xt_hashlimit_htable *hinfo __attribute__((aligned(8)));
>+};

