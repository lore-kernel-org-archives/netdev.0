From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] bridge: Module use count must be updated as	 bridges
 are created/destroyed
Date: Fri, 29 Apr 2011 12:20:01 -0400
Message-ID: <1304094001.11627.388.camel@constitution.bos.jonmasters.org>
References: <4DBA87B6020000780003ED74@vpn.id2.novell.com>
	 <20110429.011051.183061494.davem@davemloft.net>
	 <4DBA937F020000780003ED96@vpn.id2.novell.com>
	 <20110429.014445.39196872.davem@davemloft.net>
	 <4DBA9C71020000780003EDBE@vpn.id2.novell.com> <4DBA9C23.2000408@suse.cz>
	 <1304093116.11627.386.camel@constitution.bos.jonmasters.org>
	 <4DBAFE45020000780003EEE6@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jon Masters <jcm@jonmasters.org>,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	jeffm@suse.com, Michal Marek <mmarek@suse.cz>,
	netdev@vger.kernel.org
To: Jan Beulich <JBeulich@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edison.jonmasters.org ([173.255.233.168]:52138 "EHLO
	edison.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759849Ab1D2QQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 12:16:24 -0400
In-Reply-To: <4DBAFE45020000780003EEE6@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-29 at 17:07 +0100, Jan Beulich wrote:
> >>> On 29.04.11 at 18:05, Jon Masters <jonathan@jonmasters.org> wrote:
> > On Fri, 2011-04-29 at 13:08 +0200, Michal Marek wrote:
> >> On 29.4.2011 11:09, Jan Beulich wrote:
> >> >>>> On 29.04.11 at 10:44, David Miller<davem@davemloft.net>  wrote:
> > 
> >> >> Nothing on the system should be hitting modules with unload requests
> >> >> unless the user explicitly asked for that specific module to be
> >> >> unloaded.  At least not by default.
> >> >>
> >> >> So the me the problem is perhaps that "modprobe -r" does this auto
> >> >> dependency unloading thing by default.
> >> >>
> >> >> When we first fixed network device drivers so that they now properly
> >> >> always run with no module refcount at all, people complained because
> >> >> there were some distributions that ran some daemon that periodically
> >> >> looked for "unreferenced" modules and "helped" the user by
> >> >> automatically unloaded them.
> >> >>
> >> >> We killed that foolish daemon, and we can fix "modprobe -r" too.
> >> >
> >> > Michal - aren't you the modutils maintainer?
> >> 
> >> That would be Jon (CC added).
> > 
> > Thanks. So the specific feature you mention was added precisely because
> > some folks wanted to clean up ununsed modules by removing all of their
> > dependencies. Since I've not been on this thread until now, can you let
> > me know what precisely you need, and why? We can make the unloading of
> > unused modules configurable, but it sounds like you're saying even that
> > isn't good enough. What actually happens, what's the bug experience?
> 
> The problem observed was that unloading (via modprobe -r)
> ebtable_broute.ko, bridge.ko was also unloaded, causing all
> bridged networking to stop functioning on a machine.

Ah, right...ouch. That would be a "little" problem. Short of having an
exclusion list and all that nonsense, probably best to start with either
removing the unload logic or making it globally configurable. Thanks.

Jon.


