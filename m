From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Tue, 25 Aug 2015 14:20:05 -0700 (PDT)
Message-ID: <20150825.142005.1823541352876560634.davem@davemloft.net>
References: <1>
	<1c262ff7179d56eefb2c723538d1daaa88892730.1440415003.git.pdowney@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: pdowney@brocade.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1c262ff7179d56eefb2c723538d1daaa88892730.1440415003.git.pdowney@brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philip Downey <pdowney@brocade.com>
Date: Mon, 24 Aug 2015 12:39:17 +0100

> +extern int sysctl_igmp_link_local_reports;
 ...
> +/* IGMP reports for link-local multicast groups are enabled by default */
> +#define IGMP_ENABLE_LLM         1
> +
> +int sysctl_igmp_link_local_reports __read_mostly = IGMP_ENABLE_LLM;
> +
> +#define IGMP_INHIBIT_LINK_LOCAL_REPORTS(_ipaddr) \
> +	(ipv4_is_local_multicast(_ipaddr) && \
> +	 (sysctl_igmp_link_local_reports == 0))
> +

People know that "1" and "0" means enable and disable respectively, so this
macros is pretty excessive.  Just remove it.

Also, simplify the name of the sysctl to something like
"sysctl_igmp_llm_reports" or similar, and simplify the test against 0
to be in the canonical "!x" format.  Then the test can fit on one
line:

	(ipv4_is_local_multicast(_ipaddr) && !sysctl_igmp_llm_reports)
