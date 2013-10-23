From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 23 Oct 2013 08:53:13 -0400
Message-ID: <5267C6B9.4000704@mojatatu.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Felix Fietkau <nbd@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:52410 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab3JWMxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 08:53:22 -0400
Received: by mail-ie0-f181.google.com with SMTP id ar20so1159978iec.26
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 05:53:22 -0700 (PDT)
In-Reply-To: <5267BB53.8030703@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/13 08:04, Felix Fietkau wrote:


> A typical switch has something like 5-8 ports (+ one port that goes to
> the CPU),

My opinion:
So exposing the 5-8 ports as netdevs would be useful. Giving access to
their stats through per-port netdevs etc. i.e a switch/bridge will show
up on bootup and the 5-8 ports as well. The 5-8 ports will show up
as bridge ports to the switch.
If something requires other "services" like l3 - I am assuming that
would show up in the cpu port, but its role is really to demux
and send it to ingress of the originating port on ASIC (i.e dont
think it should be exposed).

>and handles the entire forwarding path on its own.

This is default behavior. i.e learning and flooding.
Can you at least retrieve the fdb? example how to figure out which
port a specific MAC address resides?

>It usually
> allows creating VLANs and assigning ports to them (tagged, untagged),

I wasnt sure about the vlans<->port mapping as i stated in the earlier
email. So on this issue, I can see the challenge.
You could of course put vlan netdevs on top of switch ports and then
attach those to the bridge, but i cant see an approach if a switch port
can support more than one vlan without having multiple bridges. example:
bridgeA: link ports {swp0:vlan1, swp1:vlan2, swp0:vlan4}
bridgeB: link ports {swp0:vlan3, swp1:vlan4, swp1:vlan2}


 > but many (probably most) switches do not support controlling the
> forwarding path via a MAC address based FDB.
>

Ok, so operations like fdb_add/del will be disallowed. This is really
up to the driver to not expose such ops.

> Many also do not have support for a packet header to indicate the
> incoming/outgoing switch port, so creating one netdev per port will work
> only for link status, not for the data path.

You mean when such a packet arrives on the "cpu" port, you wont know the
originating port?

cheers,
jamal
