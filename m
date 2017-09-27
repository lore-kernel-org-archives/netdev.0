From: Tim Hansen <devtimhansen@gmail.com>
Subject: Re: [PATCH] net/ipv4: Update sk_for_each_entry_offset_rcu macro to
 utilize rcu methods hlist_next_rcu. This fixes the warnings thrown by sparse
 regarding net/ipv4/udp.c on line 1974.
Date: Wed, 27 Sep 2017 12:25:51 -0400
Message-ID: <20170927162551.GA85447@debian>
References: <20170927005406.5935-1-devtimhansen@gmail.com>
 <20170926.200339.2029420994787006076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170926.200339.2029420994787006076.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Tue, Sep 26, 2017 at 08:03:39PM -0700, David Miller wrote:
> From: Tim Hansen <devtimhansen@gmail.com>
> Date: Tue, 26 Sep 2017 20:54:05 -0400
>
> > Signed-off-by: Tim Hansen <devtimhansen@gmail.com>
>
> This is a poor patch submission on many levels.
>

Apologies Dave, this is my first patch. I appreciate the quick review and helpful feedback.

> But the main problem, is that there is no use of
> sk_for_each_entry_offset_rcu() in any of my networking kernel trees.
>

Using the get_maintainers.pl on include/net/sock.h brings up your name and the netdev mailing list.  Forgive me if I'm misunderstanding what you mean by this?

> Referencing code by line number never works, you have to mention
> what version of the kernel, what tree, and where in what fucntion
> the problem is occurring.
>

I am using your tree net tree for now: git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git on HEAD. HEAD is c2cc187e53011c1c4931055984657da9085c763b for me currently on your tree.

Before I was on the 4.13 tag pulled from linus' tree.

The line number is indeed useless in hindsight since there are many different trees. I won't do that again.

Using sparse 0.5.0 on HEAD of your net tree, I run make C=1 net/ipv4/. It throws the error:

"net/ipv4/udp.c:1981:9: error: incompatible types in comparison expression (different address spaces)
net/ipv4/udp.c:1981:9: error: incompatible types in comparison expression (different address spaces)"

This points to the function sk_for_each_entry_offset_rcu() in __udp4_lib_mcast_deliver in net/ipv4/udp.c.

Inspecting this macro in include/net/sock.h is what lead to this patch.

Applying the patch silences those warnings but clearly this is -not- a proper way of fixing the error. Any guidance would be greatly appreciated.

> Secondly, sk_for_each_entry_offset_rcu() is not meant to be used
> in _raw() contexts.  This is why it's not called
> sk_for_each_entry_offset_rcu_raw().

Absolutely makes sense. I am not familar with the kernel naming standards fully yet but this is obvious in hindsight.

>
> The sparse warning is probably legitimate, and points to a bug.
>
> But nobody can tell where becuase you haven't told us what tree
> and where this happens.

Hopefully my reply has enough detail for reproduction and further debugging. Please let me know if I should supply any additional information.
