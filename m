From: Jan Blunck <jblunck@infradead.org>
Subject: Re: [PATCH] team: set IFF_SLAVE on team ports
Date: Thu, 9 Jul 2015 17:36:55 +0200
Message-ID: <CALe+Z03R_MPcgUSa8xoMeT5Sv3z8KwFhrtoYYzON=prfR-7hxQ@mail.gmail.com>
References: <1436435914-8903-1-git-send-email-jblunck@infradead.org>
	<20150709100727.GE2270@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150709100727.GE2270@nanopsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 9, 2015 at 12:07 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Jul 09, 2015 at 11:58:34AM CEST, jblunck@infradead.org wrote:
>>The code in net/ipv6/addrconf.c:addrconf_notify() tests for IFF_SLAVE to
>>decide if it should start the address configuration. Since team ports
>>shouldn't get link-local addresses assigned lets set IFF_SLAVE when linking
>>a port to the team master.
>
> I don't want to use IFF_SLAVE in team. Other master-slave devices are
> not using that as well, for example bridge, ovs, etc.
>

Maybe they need to get fixed too. I've used that flag because it is
documented as
a "slave of a load balancer" which describes what a team port is.


> I think that this should be fixed in addrconf_notify. It should lookup
> if there is a master on top and bail out in that case.

There are other virtual interfaces that have a master assigned and want to
participate in IPv6 address configuration.

Unless we want to have a cascade of conditionals testing the priv_flags in
addrconf_notify() this is asking for a new net_device_flags flag.
Maybe something
generic like IFF_L2PORT ?

Thanks,
Jan

[ Jiri, sorry for getting that mail twice ]
