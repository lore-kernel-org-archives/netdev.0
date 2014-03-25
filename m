From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Tue, 25 Mar 2014 21:19:45 +0000
Message-ID: <20140325211945.GC15723@casper.infradead.org>
References: <532AD5B3.6020205@mojatatu.com>
 <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>, Jiri Pirko <jiri@resnulli.us>,
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57007 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbaCYVTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 17:19:51 -0400
Content-Disposition: inline
In-Reply-To: <5331ED86.7020704@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/14 at 04:56pm, Jamal Hadi Salim wrote:
> On 03/25/14 15:35, Neil Horman wrote:
> >1) ip link show:
> >em1
> >sw1
> >
> >2) ip link show sw1
> >sw1
> >
> >3) ip link show -p sw1
> >sw1p0
> >sw1p1
> >sw1p2...
> >
> >
> >The idea is to augment user space to allow the visibiliy of ports through the
> >switch device, not directly, but using the same existing mechanisms.  We can
> >reuse all the existing infrastruture, but with this model, control must pass
> >through the switch device driver, allowing it to taylor available features by
> >passing the netlink request on to the appropriate netdevice, or sending back an
> >error itself.
> >
> 
> I think i am with you mostly - just not on the visibility of a "master"
> device.
> Expose the ports. Users create bridges bonds and if the hardware is
> capable it does the hard work to ensure consistency. No change in tools.

Exactly. This is what I meant as well. No change in tools.

It's not just about changing ip link. We have tons of existing
applications out there using Netlink and they will expect all ports
visible if they issue RTM_GETLINK with NLM_F_DUMP.

What speaks against exposing it by default? To me, the model should
not differ from a multi port NIC which we also expose all ports with
any indirection.
