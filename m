From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 17:43:57 -0700
Message-ID: <1364517837.15753.61.camel@edumazet-glaptop>
References: <20130328150410.GA22789@sergelap>
	 <CD7A1D9A.78BA%blourdel@juniper.net>
	 <20130328152040.2c905ad9@nehalam.linuxnetplumber.net>
	 <87zjxn84ks.fsf@xmission.com> <1364516016.15753.59.camel@edumazet-glaptop>
	 <87ppyj6ohh.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:50862 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283Ab3C2AoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 20:44:00 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl13so133749pab.18
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 17:44:00 -0700 (PDT)
In-Reply-To: <87ppyj6ohh.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 17:25 -0700, Eric W. Biederman wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > On Thu, 2013-03-28 at 16:52 -0700, Eric W. Biederman wrote:
> >
> >> On my microbenchmark of just creating 5000 veth pairs this takes pairs
> >> 16s instead of 13s of my earlier hacks but that is well down in the
> >> usable range.
> >
> > I guess most of the time is taken by sysctl_check_table()
> 
> All of the significant sysctl slowdowns were fixed in 3.4.  If you see
> something of sysctl show up in a trace I would be happy to talk about
> it.  The kernel side seems to be creating N network devices seems to
> take NlogN time now.  Both sysfs and sysctl store directories as
> rbtrees removing their previous bottlenecks.
> 
> The loop I timed at 16s was just:
> 
> time for i in $(seq 1 5000) ; do ip link add a$i type veth peer name b$i; done
> 
> There is plenty of room for inefficiencies in 10000 network devices and
> 5000 forks+execs.

Ah right, the sysctl part is fixed ;)

In batch mode, I can create these veth pairs in 4 seconds

for i in $(seq 1 5000) ; do echo link add a$i type veth peer name b$i;
done | ip -batch -
