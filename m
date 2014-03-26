From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 26 Mar 2014 08:19:47 -0400
Message-ID: <5332C5E3.4000500@mojatatu.com>
References: <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <5331ED86.7020704@mojatatu.com> <20140326111031.GB31370@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:42764 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbaCZMT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 08:19:56 -0400
Received: by mail-oa0-f46.google.com with SMTP id i7so2369776oag.5
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 05:19:56 -0700 (PDT)
In-Reply-To: <20140326111031.GB31370@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/14 07:10, Neil Horman wrote:
> On Tue, Mar 25, 2014 at 04:56:38PM -0400, Jamal Hadi Salim wrote:

> But by creating net_devices that are registered in the current fashion we
> implicitly agree to levels of functionality that are assumed to be available and
> as such are not within the purview of a net_device to reject.  E.g. it is
> assumed that a netdevice can filter frames using iptables/ebtables, limit
> traffic using tc, etc.

More like my response to Roopa: there are things that can be tied to 
ports and others are not.
This is where i think we need more discussion - I believe that
the offload model offered by current bridging is a good starting point
for things tied to ports. In that setup, something in the netlink header
says "give me stuff that is in the hardware" or "set this to the fdb
table in the kernel as well as in the hardware".
That is the part i like - and that concept, although tied to ports in
the case of bridging, applies generically.
Most of these things tend to be in the form of a table abstraction in
the chip.
If i add a FIB where the tie to a port is weak (occassionaly the nexthop
tie may be to a port), I should still be able to use the same method.
If this request shows up in the kernel, mechanisms are needed to shunt
it to said driver.

> And if a switch fabric is short cutting traffic so that
> the cpu doesn't see them, those bits of functionality won't work.

Separate control from data. What i am refering about is control.
Datapath and what shows up in the CPU is dependent on what gets set in
the hardware.

> I agree we
> can likely work around that with richer feature capabilities, but such an
> infrastructure would both require extensive kernel changes to fully cover the
> set of existing features at a sufficient granularity, and require user space
> changes to grok the feature set of a given device.  Not saying its impossibible
> or even undesireable mind you, just thats its not any less invasive than what
> I'm proposing.

We would need to change some things - but i think it is a small
evolution (as opposed to a revolution).

cheers,
jamal
