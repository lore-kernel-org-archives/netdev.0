From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Wed, 18 Apr 2012 00:16:50 -0400 (EDT)
Message-ID: <20120418.001650.1042781402985153056.davem@davemloft.net>
References: <4F8D497F.8060601@gmail.com>
	<20120417.223614.629911246108750471.davem@davemloft.net>
	<CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, w@1wt.eu,
	alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Carlos O'Donell" <carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org>
Date: Wed, 18 Apr 2012 00:08:47 -0400

> I don't clearly understand your position here, and perhaps that's my
> own ignorance, but could you please clarify, with examples, exactly
> why the change is not acceptable?

My position is that since millions upon millions of Linux systems, in
fact every single Linux system, exists right now with the current
behavior we are not helping application writers at all by changing
behavior now after it's been this way for nearly 20 years.

Because if an application writer wants his code to work on systems
that actually exist he has to accomodate the non-NULL termination
situation if he wants to inspect or print out an AF_UNIX path.

Because every system in existence right now allows the non-NULL
terminated AF_UNIX paths, therefore it's possible on every system
in existence right now.

Catch my drift?

The very thing the patch claims to help, it doesn't.  We install this
kernel patch now and then tell application writers that they can just
assume all AF_UNIX paths are NULL terminated when they want to print
it out, because such code will not actually be guarenteed to work on
all deployed Linux machines out there.

You cannot just ignore 20 years of precedence and say "oh let's change
this in the kernel now, and that way application writers don't have to
worry about that lack of NULL termination any more."  It simply
doesn't work like that.

All of this talk about whether applications actually create non-NULL
terminated AF_UNIX paths don't even factor into the conversation.

So the value proposition for this patch simply does not exist.
