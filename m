From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 03 Dec 2014 10:56:02 -0800
Message-ID: <547F5CC2.8000908@hp.com>
References: <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com> <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home> <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com> <20141202174158.GB9457@casper.infradead.org> <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com> <20141203090339.GA9299@redhat.com> <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com> <20141203183859.GB16447@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "Du, Fan" <fan.du@intel.com>,
	Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:57773 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbaLCS4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 13:56:10 -0500
In-Reply-To: <20141203183859.GB16447@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying to "fake-out" an ICMP message to paper-over "devices" in the 
"middle" of same Layer2 network having different MTUs from the ends goes 
back to at least the days when people started joining FDDI networks to 
Ethernet networks with bridges rather than routers.  Perhaps back even 
further.  It had problems them (including not all traffic being IP), I 
doubt today would be any different.

All devices in a Layer2 network must have the same MTU. (*)

The only exception to that which does not lead one down a rathole is 
that you can have the MTU at the "edges" of the Layer 2 network be 
smaller than the MTU in the "middle."  And then only if the middle 
"never" tries to talk itself to the edges directly.

rick jones

(*) Or at least any communicating device must be kept ignorant of what 
one does to have a smaller MTU in there somewhere.
