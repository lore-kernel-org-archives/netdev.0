From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Network privilege separation.
Date: Thu, 8 Jan 2009 06:41:45 +0100
Message-ID: <20090108054145.GU496@one.firstfloor.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <87mye2yg8a.fsf@basil.nowhere.org> <20090108023111.GJ3164@didacte.laptop.org> <20090108031042.GQ496@one.firstfloor.org> <20090108045108.GL3164@didacte.laptop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48785 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbZAHF1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 00:27:39 -0500
Content-Disposition: inline
In-Reply-To: <20090108045108.GL3164@didacte.laptop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 11:51:08PM -0500, Michael Stone wrote:
> In short, I'm trying to provide a general-purpose facility for
> 
>   * limiting networking per _process_, not per user, 
> 
>   * with an api that requires no privilege to exercise, 

While it may seem old fashioned the good old suid wrapper
is still working well for such things. That assumes you don't
want to do that in the middle of a process execution,
but that seems like a reasonable restriction.

>   * which is suitable for widespread adoption by lots of Unix vendors and
>     related standards bodies,

Hmm, I suppose RLIMIT_* does not qualify then. 

>       + when it drop privileges, it becomes unable to acquire new resources 
>       on
>         its own

That's difficult, for example are you going to disallow fork/exec?
If no then the process might still exploit something suid.

Also typically such sandbox schemes want to restrict more system
calls (basically using a white list), just in case to protect against unknown 
kernel holes in the more complex ones.

>       + though other processes may still be able to send your process tokens
>         which give it access to resources which it couldn't open on its own.
> 
> Does this help clarify the causes of my design choices?

It would be probably better if you had a few concrete use cases too
(so not just what, but also why) 

Anyways, it all sounds like more like it should be done as a special
case in a more general sandbox framework to me. Linux already
has several ones (e.g. selinux, secure computing, AA out of tree). Perhaps one
of them could be adapted to your needs.

> >Why limiting Unix sockets and not e.g. named pipes? 
> 
> Named pipes, like non-abstract unix sockets, are manageable through the
> filesystem, e.g. by DAC and namespace manipulating tools like bind-mounts 

In Linux, at least traditional BSD semantics ignore file system
access checks on Unix sockets. 

> and
> chroots.

There are more IPC mechanisms around too, e.g. sysv message passing
or queued signals with payload.  You probably need to consider
all of those.

-Andi

-- 
ak@linux.intel.com
