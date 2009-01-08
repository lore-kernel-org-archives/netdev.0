From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Network privilege separation.
Date: Thu, 8 Jan 2009 04:10:42 +0100
Message-ID: <20090108031042.GQ496@one.firstfloor.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <87mye2yg8a.fsf@basil.nowhere.org> <20090108023111.GJ3164@didacte.laptop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36820 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbZAHC4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 21:56:40 -0500
Content-Disposition: inline
In-Reply-To: <20090108023111.GJ3164@didacte.laptop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 09:31:11PM -0500, Michael Stone wrote:
>     -- if it's different from Joe User's regular uid, then where did it come
>        from and how is Joe going to clean it up when he no longer needs it?

You always create  joe-nonet one when you create joe

Now writing to joe's files: you can either use ACLs or do everything
through group accesses (it's very common to have a "joe" group for this
purpose for each user) 

But perhaps it's a good idea to not allow writing to all of Joe's
files by those "no network" processes too. It at least sounds like 
that might be useful to combine.

>   * so far as I know, netfilter is only commonly used to filter IP traffic. 
>   Can
>     I really use it to limit connections to abstract unix sockets?

No you can't. But is that really your requirement? Why limiting Unix
sockets and not e.g. named pipes? Unix sockets do not talk to the network.

I suppose I don't understand your requirements very well.

> 
>   * I think there are some problems with resource acquisition, trust, and
>     finalization:
> 
>     -- something has to work out the actual firewall rules which need to be
>        added. 
> 
>         + why should you or your sysadmin trust whatever is doing this to 
>         pick
>           the right ones?

You always define static ones at system boot. 

It would probably not scale to a lot of users, but I understand you're
talking about the OLPC which probably only has a limited set of users?

Even on a true multiuser system it could be done in a PAM module.

> 
>     -- something (with privilege) needs to install the firewall rules and 
>     needs
>        to remove unneeded rules or you've got a space leak.
> 
>         + are there any significant race conditions between whatever is
>           installing the rules and whatever is removing the dead rules?
> 
> Conclusion: so far as I can see, RLIMIT_NETWORK is, in every way, a smaller
> expansion of the end user's trusted code base and should therefore be 
> preferred
> in comparison netfilter-based solutions for process-level network privilege
> separation tasks. Do you see things differently?

Your arguments don't seem very convincing to me, but 
the big problem is more the control of incoming packets. I think
it would be possible to fix OWNER match to support the INPUT chain
though.

-Andi
-- 
ak@linux.intel.com
