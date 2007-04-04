From: Patrick McHardy <kaber@trash.net>
Subject: Re: HTB/act_mirred problem [was: one more... iproute commands	lockup
 whole system]
Date: Wed, 04 Apr 2007 16:50:11 +0200
Message-ID: <4613BB23.2050507@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>	 <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>	 <20070404125231.M65138@visp.net.lb>  <4613B273.4070801@trash.net> <1175697202.4063.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60709 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbXDDOuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 10:50:14 -0400
In-Reply-To: <1175697202.4063.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-04-04 at 16:13 +0200, Patrick McHardy wrote:
> 
>>This seems to be due to be caused by act_mirred returning TC_ACT_STOLEN,
>>which is translated to NET_XMIT_SUCCESS within prio, causing HTB to
>>increase the q.qlen counter and activating the class despite no packet
>>beeing queued.
>>
>>Jamal, we can't return NET_XMIT_SUCCESS unless we've really queued the
>>packet. I can't remeber the reason why this is done, could you remind
>>me?
> 
> 
> IIRC, It had to do with not confusing TCP to try and retransmit. 


No, that was the default return code which applies to TC_ACT_SHOT
and unclassified packets (29f1df6cc1c3ee3530939f0e38d80a9b50645ba5).
Returning NET_XMIT_SUCCESS for TC_ACT_STOLEN/TC_ACT_QUEUED has always
been done.

Anyway, we can't return NET_XMIT_SUCCESS, so how about just returning
NET_XMIT_BYPASS in all cases where the packet was stolen/dropped/...
by TC actions?

> I can
> go back and look at my notes to be certain. At one point i posted those
> notes, it maybe time to add them to the kernel code or doc somewhere.


In case they're still up to date, adding them somewhere under
Documentation/ sounds good.
