From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Wed, 14 Jul 2010 18:34:29 +0200
Message-ID: <4C3DE715.8070502@netfilter.org>
References: <20100713001115.GA3751@sortiz-mobl>	 <AANLkTil2EgQbzUqYNHAYpIWJvyyE6AWq1TpvxrqVsD7k@mail.gmail.com>	 <4C3C28EC.2000302@netfilter.org> <1279016596.12673.11.camel@chilepepper>	 <4C3C9671.5090503@netfilter.org>  <4C3DA3F4.1060807@trash.net> <1279110169.20985.41.camel@chilepepper>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: ext Patrick McHardy <kaber@trash.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56007 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962Ab0GNQeh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 12:34:37 -0400
In-Reply-To: <1279110169.20985.41.camel@chilepepper>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Luciano,

On 14/07/10 14:22, Luciano Coelho wrote:
> On Wed, 2010-07-14 at 13:48 +0200, ext Patrick McHardy wrote:
>> If you're using connection tracking, you can use conntrack marks
>> to avoid sending more than a single message:
>>
>> iptables ... -m connmark --mark 0x1/0x1 -j RETURN
>> iptables ... -j NFLOG ...
>> iptables ... -j CONNMARK --set-mark 0x1/0x1
> 
> Cool, thanks.
> 
> It seems that there are lots of possibilities to get this to work, but
> this is starting to get quite complex.  I would still prefer having the
> NFNOTIF module included, since we would be able to do what we want in a
> very simple way.  It's also probably much more efficient that using
> several rules, which would increase the CPU usage considerably (in our
> device we are already reaching the limit of a reasonable CPU resource
> usage with high throughput WLAN connections).
> 
> While I agree that it is possible to achieve the NFNOTIF functionality
> with existing modules, I still think there is a "niche" for such module,
> because it is very simple, has a very clear purpose and would make the
> ruleset simpler and more efficient.
> 
> Does this make any sense?

I don't think that the NFNOTIF infrastructure fulfill the policy for
inclusion. It seems to me like something quite specific for your needs.
It is simple, yes, but we already have this feature into the kernel. I
don't think that this will reduce CPU usage considerably with regards to
the NFLOG way.

I would still prefer adding the once-per-matching notification feature
to NFLOG than these extra lines in the kernel, Patrick?
