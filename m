From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 17:25:46 -0700
Message-ID: <87ppyj6ohh.fsf@xmission.com>
References: <20130328150410.GA22789@sergelap>
	<CD7A1D9A.78BA%blourdel@juniper.net>
	<20130328152040.2c905ad9@nehalam.linuxnetplumber.net>
	<87zjxn84ks.fsf@xmission.com>
	<1364516016.15753.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:43963 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283Ab3C2AZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 20:25:56 -0400
In-Reply-To: <1364516016.15753.59.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Thu, 28 Mar 2013 17:13:36 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Thu, 2013-03-28 at 16:52 -0700, Eric W. Biederman wrote:
>
>> On my microbenchmark of just creating 5000 veth pairs this takes pairs
>> 16s instead of 13s of my earlier hacks but that is well down in the
>> usable range.
>
> I guess most of the time is taken by sysctl_check_table()

All of the significant sysctl slowdowns were fixed in 3.4.  If you see
something of sysctl show up in a trace I would be happy to talk about
it.  The kernel side seems to be creating N network devices seems to
take NlogN time now.  Both sysfs and sysctl store directories as
rbtrees removing their previous bottlenecks.

The loop I timed at 16s was just:

time for i in $(seq 1 5000) ; do ip link add a$i type veth peer name b$i; done

There is plenty of room for inefficiencies in 10000 network devices and
5000 forks+execs.

Eric
