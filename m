From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 12/19] net neighbour:  Convert to use register_net_sysctl
Date: Fri, 20 Apr 2012 00:25:07 -0700
Message-ID: <m1ty0ec1bg.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
	<m1ehrjfg2s.fsf@fess.ebiederm.org> <4F90F26B.3090906@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	"pablo\@netfilter.org" <pablo@netfilter.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:34614 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557Ab2DTHVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 03:21:08 -0400
In-Reply-To: <4F90F26B.3090906@parallels.com> (Pavel Emelyanov's message of
	"Fri, 20 Apr 2012 09:21:47 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@parallels.com> writes:

>> @@ -2925,19 +2924,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
>>  {
>>  	struct neigh_sysctl_table *t;
>>  	const char *dev_name_source = NULL;
>> -
>> -#define NEIGH_CTL_PATH_ROOT	0
>> -#define NEIGH_CTL_PATH_PROTO	1
>> -#define NEIGH_CTL_PATH_NEIGH	2
>> -#define NEIGH_CTL_PATH_DEV	3
>> -
>> -	struct ctl_path neigh_path[] = {
>> -		{ .procname = "net",	 },
>> -		{ .procname = "proto",	 },
>> -		{ .procname = "neigh",	 },
>> -		{ .procname = "default", },
>> -		{ },
>> -	};
>> +	char neigh_path[ sizeof("net//neigh/") + IFNAMSIZ + IFNAMSIZ ];
>
> Why two IFNAMSIZ-es? One is for the dev->name, but the other one is not.
> Is it just for not having any other better constant at hands?

Yep.  We don't seem to have any proto name size constants, and all
of decnet ipv4 and ipv6 are all shorter than the 16 bytes of IFNAMSIZ.

Even if I am wrong the snprintf below truncates it's output to the
buffer size and null terminates it so in the worst case we won't cause
a buffer overflow, we will just get a truncated path name to pass
to sysctl.

Shrug I stopped at good enough but I am happy for a better number.

Eric

>>  	t = kmemdup(&neigh_sysctl_template, sizeof(*t), GFP_KERNEL);
>>  	if (!t)
