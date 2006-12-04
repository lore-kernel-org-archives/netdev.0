From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED]: cls_fw: fix NULL pointer dereference
Date: Mon, 04 Dec 2006 17:39:29 +0100
Message-ID: <45744F41.8020609@trash.net>
References: <45744016.8080707@trash.net> <1165249502.3643.9.camel@localhost> <20061204162823.GQ8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48686 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937110AbWLDQgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 11:36:22 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061204162823.GQ8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-12-04 11:25
> 
>>On Mon, 2006-04-12 at 16:34 +0100, Patrick McHardy wrote:
>>
>>>Fix a regression from my nfmark mask patch for cls_fw.
>>>
>>>Thomas, Jamal, do you have an idea what this "old method" stuff
>>>is used for? It seems it is only used during the below mentioned
>>>race.
>>
>>AFAIK, that has been there forever. Alexey may know. I am not
>>sure if removing it will break any scripts etc.
> 
> 
> You mean the scripts get upset when the kernel oopses?

Well, it won't oops without my broken patch :)

It just seems this code is entirely useless and the only
thing it does is cause short term unexpected behaviour
during the race I mentioned.

One thing we should probably do is to move the tp->root
allocation to the init function in cls_fw and the others
implementing it as dummy to at least close the race
between ->init and ->change. I'll look into that as a
follow-up patch.
