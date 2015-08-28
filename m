From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Fri, 28 Aug 2015 13:33:40 -0700
Message-ID: <1440794020.8932.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <20150827.113823.214019265460582055.davem@davemloft.net>
	 <55E00238.10909@linux.vnet.ibm.com>
	 <20150828.112413.424099339331017970.davem@davemloft.net>
	 <1440789654.11525.137.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	raghavendra.kt@linux.vnet.ibm.com, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	serge.hallyn@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440789654.11525.137.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-08-28 at 12:20 -0700, Joe Perches wrote:

> I don't read it as particularly different.
> 
> There are > 100 uses of the not quite a memset initialization
> style using "= { <0,> }" in net/
> 
> $ git grep -E "=\s*\{\s*0?\s*,?\s*\}" net | wc -l
> 138
> 
> There is a difference though if a struct is copied to
> user-space as a {} initialization only guarantees that
> struct members are initialized to 0 where memset also
> zeros any alignment padding.

We do not bother for small struct.

Here, the array is big enough that David prefers having an explicit
memset() so that it clearly shows that author of this code was aware of
this.
