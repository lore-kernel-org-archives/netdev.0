From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Thu, 27 Aug 2015 11:38:23 -0700 (PDT)
Message-ID: <20150827.113823.214019265460582055.davem@davemloft.net>
References: <y>
	<1440610653-14210-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, edumazet@google.com,
	hannes@stressinduktion.org, tom@herbertland.com, azhou@nicira.com,
	ebiederm@xmission.com, ipm@chirality.org.uk,
	nicolas.dichtel@6wind.com, serge.hallyn@canonical.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	anton@au1.ibm.com, nacc@linux.vnet.ibm.com,
	srikar@linux.vnet.ibm.com
To: raghavendra.kt@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Date: Wed, 26 Aug 2015 23:07:33 +0530

> @@ -4641,10 +4647,12 @@ static inline void __snmp6_fill_stats64(u64 *stats, void __percpu *mib,
>  static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
>  			     int bytes)
>  {
> +	u64 buff[IPSTATS_MIB_MAX] = {0,};
> +
>  	switch (attrtype) {
>  	case IFLA_INET6_STATS:
> -		__snmp6_fill_stats64(stats, idev->stats.ipv6,

I would suggest using an explicit memset() here, it makes the overhead incurred
by this scheme clearer.

Thanks.
