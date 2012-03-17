From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] adjust __net_exit
Date: Fri, 16 Mar 2012 22:18:13 -0700 (PDT)
Message-ID: <20120316.221813.236130733754848615.davem@davemloft.net>
References: <4F588BEC020000780007710A@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	sam@ravnborg.org, xemul@openvz.org, ebiederm@xmission.com
To: JBeulich@suse.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4F588BEC020000780007710A@nat28.tlf.novell.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jan Beulich" <JBeulich@suse.com>
Date: Thu, 08 Mar 2012 09:37:32 +0000

> __net_exit, judging by the majority of its uses, was intended to serve
> as an abstraction to allow calling such annotated functions from both
> __init and __exit functions. Using the (bogus and unused elsewhere)
> __exit_refok to implement this is inefficient - any non-modular code
> really can reside in __init (as non-modular __exit code is never used).
> 
> Therefore, adjust __net_exit to resolve to nothing (i.e. normal .text)
> in modules, and __init in the core kernel.
> 
> A few other adjustments are necessary/possible with this done - those
> were likely just oversights when added originally.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

[ I have been waiting for more than a week for a netns developer
  to review this patch, I guess I'm too optimistic these days. :-( ]

The only reason you think __exit_refok is "bogus" is because it's
semantics got changed by Sam Ravnborg in commit
312b1485fb509c9bc32eda28ad29537896658cb8 ("Introduce new section
reference annotations tags: __ref, __refdata, __refconst")

Beforehand the __exit_refok was a real .exit section, so it got
completely discarded AT LINK TIME.  Now it sits together with
__init_refok which is an unremovable kernel image section, which
neither gets removed at compile time nor boot time.

So __exit_refok did exactly what you say it should do before Sam's
change.

It's just completely stupid to change the netns section defines,
and instead we should revert __exit_refok to mean what it always
meant previously.

I'm not applying this patch.
