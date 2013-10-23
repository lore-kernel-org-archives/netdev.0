From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 23 Oct 2013 07:47:48 -0400
Message-ID: <5267B764.305@mojatatu.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Felix Fietkau <nbd@openwrt.org>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35950 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381Ab3JWLr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 07:47:58 -0400
Received: by mail-ie0-f181.google.com with SMTP id ar20so1040831iec.40
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 04:47:58 -0700 (PDT)
In-Reply-To: <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/13 18:09, Florian Fainelli wrote:
> 2013/10/22 Neil Horman <nhorman@tuxdriver.com>:
>> On Tue, Oct 22, 2013 at 12:59:12PM -0700, Florian Fainelli wrote:
>>> 2013/10/22 John Fastabend <john.r.fastabend@intel.com>:
>>>> On 10/22/2013 11:23 AM, Florian Fainelli wrote:
>>>>>
>
>>>
>>> Ok, I know nothing about the FDB API, but will take a look and see if
>>> that sounds suitable for the embedded use cases.
>>>
>> Further to Johns comments, why are you creating a new netlink protocol for this?
>> It seems that 90% of what you want to accomplish above is handled by rtnetlink.
>> As long as you write your driver properly, most of that should "just work".
>
> This is not a new netlink protocol, but a generic netlink family. Why
> would I extend rtnetlink to cover the remaining 10% which are not
> going to be used on desktop and servers when a new generic netlink
> family is cheap and can be selectively disabled in the kernel?
>

Florian,

I think it would be fantastic if you adopt the FDB API. The comment
to use rtnetlink configure is valid. You can configure hardware
switches as John has shown. I realize you guys have invested
tons of time and this stuff has been tested by tons of people and this
is a painful exercise to go through, but:
having more than one approach for configuring/controlling kernel
switch interfaces is not ideal. If you use the rtnetlink API then one
can configure both the Linux bridge, embedded intel switches, etc with
iproute2. i.e the switch becomes a bridge. I see a lot of commonolity
between your model based on what you described and the current bridge.
Pull the latest iproute2 code and look at "bridge" command.

Essentially, the current bridged could be described as an entity
that does L2 switching:
a) it has bridge ports which are any netdevs on Linux
b) it has an FDB which constitutes a MAC address as the lookup and 
optionally a VLAN. You can control learning and flooding.
c) it has vlan filtering capabilities which you can turn on/off. The
vlan capability to sellect PVIDs is also built in.
d) It has multicast snooping

I think your model needs #a and #b, you can ignore the rest.
I am not quiet sure how vlan port membership will apply; an fdb for
each entry will have a vlan. You could also create one bridge per vlan
(not the best  approach) - ccing Vlad and Stephen.


cheers,
jamal
