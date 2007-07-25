From: Patrick McHardy <kaber@trash.net>
Subject: Re: Tc filtering: broken 802_3 classifier?
Date: Thu, 26 Jul 2007 01:11:14 +0200
Message-ID: <46A7D892.3020505@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329034BF7F6@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61233 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760295AbXGYXMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 19:12:18 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329034BF7F6@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>Waskiewicz Jr, Peter P wrote:
>>
>>I'm not sure what you're expecting. skb->protocol is usually not set
>>to ETH_P_802_3, which is why the filter is not matching.
> 
> 
> I understand that.  I had two issues, which you cleared up one by
> reminding me that the protocol matches on skb->protocol before it tries
> to run the ->classify() routine.  The other issue I am seeing is with 8
> bands, an 802_3 filter is affecting classification of IP traffic.  For
> example, I have an 802_3 filter to look for dst MAC address, but an ssh
> packet, which without any filters should go into flowid 1:3 on my
> system, is getting pushed into flowid 1:1.  I remove the 802_3 filter,
> and ssh traffic starts going back into 1:3.  No other filters on the
> system.  That's the main issue I'm seeing, so I'll keep investigating to
> see what's going on.


In case of prio, if your manually installed filters don't match, it will
fall back to the skb->priority based classification, which is based
on tos and is probably responsible for what you're seeing. Feel free to
investigate, but you could save us all some time by simply posting what
you're doing, what you're expecting and what is actually happening,
there's probably a good explanation.

