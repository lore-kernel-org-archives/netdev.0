From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Mon, 13 Apr 2015 09:26:00 +0100
Message-ID: <20150413082600.GA16323@casper.infradead.org>
References: <20150412075351.GA2112@nanopsycho.orion>
 <20150412.194443.1571071793033525091.davem@davemloft.net>
 <20150413001212.GA1656@Alexeis-MBP.westell.com>
 <20150412.203618.86474109049619893.davem@davemloft.net>
 <20150413010342.GA1672@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org, jhs@mojatatu.com, jesse@nicira.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48120 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236AbbDMI0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 04:26:03 -0400
Content-Disposition: inline
In-Reply-To: <20150413010342.GA1672@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/15 at 06:03pm, Alexei Starovoitov wrote:
> On Sun, Apr 12, 2015 at 08:36:18PM -0400, David Miller wrote:
> > 
> > It's easy to parameterize what flow dissector does and share code.
> 
> yes. Though I wouldn't pessimize ixgbe rx path even by single
> cycle to accommodate openflow spec. As far as I understand the
> skb_flow_dissect() job from driver point of view is to figure
> out header length for copybreak, which includes parsing encaps,
> whereas openflow stops at outer header. Even with this difference,
> it surely can be parameterized. Would be great to share if it
> doesn't cost rx anything.

A flow dissector that only extracts what's needed would benefit
everyone. I guess static keys could help here as the flow field
selection is definitely a slow path operation.

Even OVS could benefit from this eventually, it would just need
to do a full extract before the key is sent to user space.

Also, the logic to generate the wildcard mask and match on it
should be generalized as well.
