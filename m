From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Mon, 15 Sep 2003 23:02:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915230259.79f5a545.davem@redhat.com>
References: <200309022116.41697.bdschuym@pandora.be>
	<200309132159.37834.bdschuym@pandora.be>
	<20030915155903.12a3f95d.davem@redhat.com>
	<200309160805.08171.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309160805.08171.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2003 08:05:07 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> Anyway, this rule about not changing structs exported to userspace truly 
> sucks, IMHO.

Welcome to the real world.

> If someone decides to compile her own kernel this person should 
> not expect every userspace tool to keep working, again IMHO.

Wouldn't it be great if you recompiled you kernel and the args
to the read() system call got rearranged?

There is simply no difference in this case.  The situation doesn't
change because the object is being passed into some netfilter module.

You can't arbitrarily change userland exported APIs at your convenience
to fix some bug.  You either have to create a new interface for the user
to use, or fix the bug without changing the API.

Will it be the end of the world if you do a byte at a time comparison,
at least as a temporary solution?

Also, another solution could be to store the object inside the kernel
using a different structure, one where you can guarentee the alignment
of these things properly.
