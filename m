From: Andi Kleen <ak@suse.de>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 20:37:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008183742.GA24822@wotan.suse.de>
References: <3F844578.40306@sgi.com> <20031008101046.376abc3b.davem@redhat.com> <3F8455BE.8080300@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, johnip@sgi.com, netdev@oss.sgi.com,
        jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
Content-Disposition: inline
In-Reply-To: <3F8455BE.8080300@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The problem is that on the Altix platform they have to deal with unaligned 
> accesses via an exception handler.  This causes them to run through 
> hundreds of instructions.  There's evidntally another mechanism in the cpu 
> that's more efficient in daling with unaligned accesses, but we can't use 
> that for some reason (atomicity I think, but I don't recall).

Atomicity should not be needed to access a private skb.

Maybe you didn't want to change the core stack to use the unaligned
access mechanism?

In that case it may be better to fix the stack with some macro
that expands to the unaligned access on IA64 and a normal load 
on other architectures.

-Andi
