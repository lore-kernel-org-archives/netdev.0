From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Tc filtering: broken 802_3 classifier?
Date: Wed, 25 Jul 2007 10:34:18 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329034BF7F6@orsmsx414.amr.corp.intel.com>
References: <46A7884F.70707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10398 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762219AbXGYRed convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 13:34:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46A7884F.70707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Waskiewicz Jr, Peter P wrote:
> >>The protocol match is on skb->protocol, so it case of 
> ethernet its on 
> >>the ethernet protocol, which is ETH_P_IP or "ip" for IPv4.
> > 
> > 
> > I see that in the code, but the reason I started worrying was when I
> > added the 802_3 classifier on 8 flows, it would shove all 
> traffic into
> > flowid 1:1, no matter if it matched or not.
> > 
> > I'll keep investigating and see if I can narrow down what 
> I'm seeing.
> 
> 
> I'm not sure what you're expecting. skb->protocol is usually not set
> to ETH_P_802_3, which is why the filter is not matching.

I understand that.  I had two issues, which you cleared up one by
reminding me that the protocol matches on skb->protocol before it tries
to run the ->classify() routine.  The other issue I am seeing is with 8
bands, an 802_3 filter is affecting classification of IP traffic.  For
example, I have an 802_3 filter to look for dst MAC address, but an ssh
packet, which without any filters should go into flowid 1:3 on my
system, is getting pushed into flowid 1:1.  I remove the 802_3 filter,
and ssh traffic starts going back into 1:3.  No other filters on the
system.  That's the main issue I'm seeing, so I'll keep investigating to
see what's going on.

-PJ
