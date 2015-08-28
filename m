From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC V2 2/2] net: Optimize snmp stat aggregation by
 walking all the percpu data at once
Date: Fri, 28 Aug 2015 14:14:47 -0700
Message-ID: <1440796487.8932.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440610653-14210-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	 <20150827.113823.214019265460582055.davem@davemloft.net>
	 <55E00238.10909@linux.vnet.ibm.com>
	 <20150828.112413.424099339331017970.davem@davemloft.net>
	 <1440789654.11525.137.camel@perches.com>
	 <1440794020.8932.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440795211.11525.146.camel@perches.com>
	 <1440795336.8932.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440796183.11525.153.camel@perches.com>
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
In-Reply-To: <1440796183.11525.153.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-08-28 at 14:09 -0700, Joe Perches wrote:
> On Fri, 2015-08-28 at 13:55 -0700, Eric Dumazet wrote:
> > On Fri, 2015-08-28 at 13:53 -0700, Joe Perches wrote:
> > > On Fri, 2015-08-28 at 13:33 -0700, Eric Dumazet wrote:
> > > > We do not bother for small struct.
> > > > 
> > > > Here, the array is big enough that David prefers having an explicit
> > > > memset() so that it clearly shows that author of this code was aware of
> > > > this.
> > > 
> > > It's 288 bytes on stack, maybe a kzalloc would be clearer too.
> > 
> > Could you read patch history and check why this has been rejected ?
> 
> I don't see a rejection, just that the initial
> submission didn't check the allocation or add
> an allocation buffer via kcalloc/kzalloc to the
> inet6_fill_ifla6_attrs caller and change the
> snmp6_fill_stats arguments.
> 
> It could also eliminate the put_unaligned calls.

Not really. You do not properly read this code.

put_unaligned is happening on a space allocated from rtnetlink skb, not
the temp space needed to perform the per cpu folding.

> 
> https://lkml.org/lkml/2015/8/25/114
> 
> Was there some other thread?

Same thread

https://lkml.org/lkml/2015/8/25/476
