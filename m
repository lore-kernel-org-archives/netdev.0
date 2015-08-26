From: Philip Downey <pdowney@Brocade.com>
Subject: RE: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Wed, 26 Aug 2015 09:23:17 +0000
Message-ID: <6807a59f7e9f48b6992261c1ec0562b2@EMEAWP-EXMB12.corp.brocade.com>
References: <1>
	<1c262ff7179d56eefb2c723538d1daaa88892730.1440415003.git.pdowney@brocade.com>
 <20150825.142005.1823541352876560634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150825.142005.1823541352876560634.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, August 25, 2015 10:20 PM
> To: Philip Downey
> Cc: kuznet@ms2.inr.ac.ru; jmorris@namei.org; yoshfuji@linux-ipv6.org;
> kaber@trash.net; linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
> 
> From: Philip Downey <pdowney@brocade.com>
> Date: Mon, 24 Aug 2015 12:39:17 +0100
> 
> > +extern int sysctl_igmp_link_local_reports;
>  ...
> > +/* IGMP reports for link-local multicast groups are enabled by default */
> > +#define IGMP_ENABLE_LLM         1
> > +
> > +int sysctl_igmp_link_local_reports __read_mostly = IGMP_ENABLE_LLM;
> > +
> > +#define IGMP_INHIBIT_LINK_LOCAL_REPORTS(_ipaddr) \
> > +	(ipv4_is_local_multicast(_ipaddr) && \
> > +	 (sysctl_igmp_link_local_reports == 0))
> > +
> 
> People know that "1" and "0" means enable and disable respectively, so this
> macros is pretty excessive.  Just remove it.
> 
> Also, simplify the name of the sysctl to something like
> "sysctl_igmp_llm_reports" or similar, and simplify the test against 0 to be in
> the canonical "!x" format.  Then the test can fit on one
> line:
> 
> 	(ipv4_is_local_multicast(_ipaddr) && !sysctl_igmp_llm_reports).

Thanks for reviewing David.
I will make the requested changes  (fitting the test on a single line was my main reason for introducing the macro - that and making it patently obvious what the test was doing.  Your suggestion would seem to meet that aim).

Will amend and resubmit.

Regards

Philip
