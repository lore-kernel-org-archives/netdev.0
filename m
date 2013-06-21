From: Jan Engelhardt <jengelh@inai.de>
Subject: RE: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in
 absence of MSS option
Date: Fri, 21 Jun 2013 10:27:18 +0200 (CEST)
Message-ID: <alpine.LSU.2.10.9.1306211016250.3279@nerf07.vanv.qr>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org> <1370880461-4265-4-git-send-email-pablo@netfilter.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7282@saturn3.aculab.com> <20130610071954.GA13500@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7285@saturn3.aculab.com>
 <20130610082739.GA14277@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7286@saturn3.aculab.com> <20130611162525.GA11547@localhost> <4E5779AD88B2F040B8A7E83ECF544D1A016005@SJCPEX01CL02.citrite.net> <51B768EC.4090504@hp.com>
 <4E5779AD88B2F040B8A7E83ECF544D1A01622C@SJCPEX01CL02.citrite.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: 'Rick Jones' <rick.jones2@hp.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Phil Oester <kernel@linuxace.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Haran <Jeff.Haran@citrix.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4E5779AD88B2F040B8A7E83ECF544D1A01622C@SJCPEX01CL02.citrite.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2013-06-11 20:31, Jeff Haran wrote:
>> > It seems the version of
>> > the DHCP client that came with the new distro honored the DHCP MTU
>> > option, but Comcast was advertising DHCP offers with an MTU of 576.
>>
>> Did your SuSE system send actual TCP MSS options based on the 576
>> byte MTU?

Yes and it makes for horrible performance. In fact, the "Unitymedia"
cable provider in Germany does exactly the same stupid thing, sending
MTU=576 in their DHCP responses, despite the link actually being
capable of MTU 1500 ("capable" as in, not returning a Fragmentation
Needed ICMP). The only way to get around this provider's idiocy is to
manually set MTU=1500 in SUSE's network config, which overrides the
DHCP values. The way it works is probably by way of using the
scripting functions of prominent DHCP and VPN clients (the C programs
only does the network job and otherwise calls /bin/sh-type logic to
actually modify the interface parameters) like dhclient,dhcpcd,vpnc.


>> Presumably then, your system rejected any incoming packet which was
>> larger than the 576 byte MTU it got from the Comcast DHCP server..

The MTU is not used to block incoming packets. That would not make
sense either (because you already have received the packet and
therefore can use it). In fact, TCP-receive-offloading hardware may
even pass to the kernel packets that are larger than both the output
MTU of your own system as well as larger as the output MTU of the
router you got it from.
