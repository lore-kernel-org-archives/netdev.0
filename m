From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 30 Oct 2013 12:58:44 +0100
Message-ID: <5270F474.3000702@openwrt.org>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>	 <1382466229-15123-2-git-send-email-f.fainelli@gmail.com>	 <5266D7D6.9000309@intel.com>	 <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com>	 <20131022202537.GA16336@hmsreliant.think-freely.org>	 <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com>	 <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org>	 <5267C6B9.4000704@mojatatu.com> <1383088365.16822.22.camel@sakura.staff.proxad.net> <5270F282.6000708@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>, mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:38207 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300Ab3J3L7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 07:59:04 -0400
In-Reply-To: <5270F282.6000708@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-30 12:50, Jamal Hadi Salim wrote:
> On 10/29/13 19:12, Maxime Bizon wrote:
> 
>>
>>  From a user POV, when you see a netdevice, you expect to be able to
>> receive or send packets from/to it. The ability to read stats/link is
>> only a secondary feature.
>>
> 
> The important part is all the APIs stay consistent. I can use
> same netlink calls. ifconfig works.
> iproute2 works. People have written books on this stuff - we dont
> have MCSE(Must Call Software Engineer) certification, but this is
> as close as it gets. i.e the knowledge has been commoditized, even
> my kid knows how to use these tools.
> 
> If i can get stats by doing ifconfig - that should provide illusion that
> the netdevice is sending/receiving packets.
Pretty much all of the above have serious limitations when you're not
actually able to run the data path through the per-port netdevs.
You can't assign IP addresses to them. The network stack will probably
even attempt to assign IPv6 link-local addresses to these things,
causing even more confusion.
You can't add them to normal software bridges like other devices.
You can't use bonding. I could probably go on for a while.
There's a huge list of things that you simply cannot do with these
interfaces, and without knowing the details of the implementation, users
will be left clueless as to why that is.
I'd say that's a very serious violation of the principle of least surprise.
And knowing what the typical OpenWrt users do with their devices, I can
already forsee the bogus bug reports trickling in, if this is to be
implemented.

- Felix
