From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 12/19] net neighbour:  Convert to use
 register_net_sysctl
Date: Sun, 22 Apr 2012 03:36:55 +0100
Message-ID: <1335062215.3209.330.camel@deadeye>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
	 <m1ehrjfg2s.fsf@fess.ebiederm.org> <4F90F26B.3090906@parallels.com>
	 <m1ty0ec1bg.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24561 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751975Ab2DVCmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 22:42:32 -0400
In-Reply-To: <m1ty0ec1bg.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-20 at 00:25 -0700, Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@parallels.com> writes:
> 
> >> @@ -2925,19 +2924,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
> >>  {
> >>  	struct neigh_sysctl_table *t;
> >>  	const char *dev_name_source = NULL;
> >> -
> >> -#define NEIGH_CTL_PATH_ROOT	0
> >> -#define NEIGH_CTL_PATH_PROTO	1
> >> -#define NEIGH_CTL_PATH_NEIGH	2
> >> -#define NEIGH_CTL_PATH_DEV	3
> >> -
> >> -	struct ctl_path neigh_path[] = {
> >> -		{ .procname = "net",	 },
> >> -		{ .procname = "proto",	 },
> >> -		{ .procname = "neigh",	 },
> >> -		{ .procname = "default", },
> >> -		{ },
> >> -	};
> >> +	char neigh_path[ sizeof("net//neigh/") + IFNAMSIZ + IFNAMSIZ ];
> >
> > Why two IFNAMSIZ-es? One is for the dev->name, but the other one is not.
> > Is it just for not having any other better constant at hands?
> 
> Yep.  We don't seem to have any proto name size constants, and all
> of decnet ipv4 and ipv6 are all shorter than the 16 bytes of IFNAMSIZ.

I don't think it makes any sense to put in IFNAMSIZ as a size for a
string that isn't a device name.

> Even if I am wrong the snprintf below truncates it's output to the
> buffer size and null terminates it so in the worst case we won't cause
> a buffer overflow, we will just get a truncated path name to pass
> to sysctl.
> 
> Shrug I stopped at good enough but I am happy for a better number.

Truncation by snprintf() is definitely better than overflow, but we
should also check and WARN so that if someone breaks this it's hard to
miss.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
