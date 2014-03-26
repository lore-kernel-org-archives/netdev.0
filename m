From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 26 Mar 2014 06:54:54 -0400
Message-ID: <5332B1FE.7080102@mojatatu.com>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us> <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <5332677F.2090404@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, Thomas Graf <tgraf@suug.ch>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:49529 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbaCZKy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 06:54:59 -0400
Received: by mail-ob0-f172.google.com with SMTP id wm4so2241818obc.3
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 03:54:59 -0700 (PDT)
In-Reply-To: <5332677F.2090404@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/14 01:37, Roopa Prabhu wrote:
> On 3/25/14, 1:11 PM, Florian Fainelli wrote:
>> 2014-03-25 12:35 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:

> Sorry about getting on this thread late and possibly in the middle.
> Agree on the idea of keeping the ports linked to the master switch dev
> (or the 'conduit' to the switch chip) via private list instead of the
> master-slave relationship proposed earlier.
> By private i mean the netdev->priv linkage to the master switch dev and
> not really keeping the ports from being exposed to the user.
>
> We think its better to keep the switch ports exposed as any other netdev
> on linux.
>   This approach will make the switch ports look exactly like a nic port
> and all tools will continue to work seamlessly. The switch port
> operations could internally be forwarded to the switch netdev (sw1 in
> the above case).
>
> example:
> $ip link set dev sw1p0 up
> $ethtool -S sw1p0
>

I like the approach. I know the above is a simple version, but i am
assuming you also mean i can do things like
ip route add ...
bridge fdb add ... (and if you like your brctl go ahead)
bonding ...



>
> whether sw1 is needed as a separate netdev existing on the system is
> debatable.

I dont see need to expose it. For 1, it will be confusing to have this
netdev whose only task is to control the chip.

> Most cases the switch port driver (API) can talk to the switch chip
> driver without a switch netdev in between.
> But there are cases where a switch netdev might become necessary for
> switch chip specific operations (which probably has been discussed on
> this thread). An example could be a global acl rule that applies to all
> switch ports. One can argue that this can be applied on individual
> switch ports and the switch driver can take care of consolidating or
> optimally programming the acl rule in the switch chip.
>

There are a lot of things which dont tie to a specific port.
I think these should be transparent to the chip. If i add a route
and the decision is for that route to go to the chip, then it
shows up at the driver and it goes to the ASIC.
If i am dumping a fib table and some parts of it sit in the chip,
then whatever interfaces would end up querying the chip.

cheers,
jamal


> Thanks,
> Roopa
>
>
>
>
>
