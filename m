From: jamal <hadi@cyberus.ca>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 04 Apr 2007 22:14:54 -0400
Message-ID: <1175739294.4068.29.camel@localhost>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>
	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>
	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>
	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>
	 <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>
	 <4613A9F6.8000307@trash.net> <1175695102.4063.4.camel@localhost>
	 <4613B13C.3010603@trash.net> <1175697054.4063.13.camel@localhost>
	 <4613B890.4000005@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:64224 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915AbXDECPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 22:15:00 -0400
Received: by wx-out-0506.google.com with SMTP id h31so442338wxd
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2007 19:14:59 -0700 (PDT)
In-Reply-To: <4613B890.4000005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-04 at 16:39 +0200, Patrick McHardy wrote:

> Have a tasklet to avoid the deadlocks.

sounds like a good idea from the outset. The principle of punishing only
users of mirred is the right one. It will also provide a clean way to
drop all redirect to self.

The dilema is that the cost may end up being in complexity and
performance. Let me throw a few wrenches your way:
- Mirroring doesnt have this problem, only redirecting does. And the
main problem is on egress. So you may have to do the enqueueing only for
those cases, or we may just have to separate redirects from mirroring as
two separate actions. 
- We need to be able to support literally hundreds of such actions, so
if you do a single tasklet per action you will have quiet a few running
- i dont know what the impact is. A solution might be to do a single
tasklet with the mirred table; you will need many queues.
-There may be others like lock contention etc on trying to reinject
which will affect perfomance.
 
I am not against the idea Patrick, I am just worried about performance
and i feel that the majority of people who redirect will, once bitten
(as was Denys), eventually resort to doing the right config and would
rather have good perfomance. 

I could be selfish and wrong by looking at my needs for this action but
i prefer performance and from that perspective i look at this from
someone who didnt read the instructions on a gun and shot at their toe.
You could add a sensor that recognises a toe is being aimed at and pop
up an LCD with a question "are you sure you want to shoot at _a
toe_?" ;-> but that adds to the cost.
I am exagerating - but i hope you get my point.  

cheers,
jamal

