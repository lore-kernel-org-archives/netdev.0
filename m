From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: VRFs and the scalability of namespaces
Date: Fri, 26 Sep 2014 18:25:50 -0700
Message-ID: <87vbo9kg69.fsf@x220.int.ebiederm.org>
References: <5425EAA6.7040302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nicolas.dichtel@6wind.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:47182 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbaI0B0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 21:26:16 -0400
In-Reply-To: <5425EAA6.7040302@gmail.com> (David Ahern's message of "Fri, 26
	Sep 2014 16:37:26 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> writes:

> Hi Eric:
>
> As you suggested [1] I am starting a new thread to discuss scalability
> problems using namespaces for VRFs.

I will accept as a given that using network namespaces at a scale of
1000s and with lots of little applications listening for new connections
(but generally not doing anything) is outside the classic networking
usage of linux and of namespaces and so does not work out of the box and
that very least some fixes are necessary.

However your premise that network namespaces are unsupportable unfixable
and fundamentally unscalable for what you want to do is unsupported.

The most difficult problem for high levels of efficiency is that that of
modifying applications so that they are VRF/namespace aware.  That they
look at the appropriate set of dns resolvers for the namespace, that
when messages are logged the messages report not just the ip address but
the context that ip address came from.  There are no magic solutions to
make that kinds of deep and fundamental code modifications.

I can totally see it being frustrating to use linux as a switch OS
when it doesn't quite do what you want on the hardware you want to use,
and definitely not with the efficiencies you want.

I will tell you what network namespaces get you.  Network namespaces
deliver the full power of the linux network stack, every interesting
feature works, and network namespaces provide a path where you can use
unmodified linux applications.

When you say "proper VRF support" what I hear is that you think
something new needs to be added to the linux network stack (called a
VRF) with a new userspace interface that somehow because it lacks
features is better.

> Background
> ----------
> Consider a single system that wants to provide VRF-based features with
> support for N VRFs. N could easily be 2048 (e.g., 6Wind, [2]), 4000
> (e.g., Cisco, [3]) or even higher.
>
> The single system with support for N VRFs runs M services (e.g.,
> quagga, cdp, lldp, stp, strongswan, some homegrown routing protocol)
> and includes standard system services like sshd. Furthermore, a system
> also includes monitoring programs like snmpd and tcollector. In short,
> M is easily 20 processes that need to have a presence across all VRFs.

And trying to run it all on what would be considered an underpowered in
most contexts.

> Before droning on even more, does the above provide better context on
> the general problem?

It provides a rough context on what you are trying to do.  Use linux as
the OS to run on a switch.

It doesn't actually provide much in the way of context actual problems
that show up when you try to use network namespaces.  Which is what I
was expecting the discussion would be about, and which would I expect be
a productive conversation.

Eric
