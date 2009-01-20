From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal
 firewalls"
Date: Tue, 20 Jan 2009 19:24:57 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0901201916340.516@fbirervta.pbzchgretzou.qr>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, sam@synack.fr
To: Stephan Peijnik <stephan@peijnik.at>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1232473719.24943.102.camel@sp-laptop3.sp-local>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2009-01-20 18:48, Stephan Peijnik wrote:
>
>A personal firewall should implement per-application mandatory access
>control for sockets. In short this means that such a program decides
>every time a call to either socket(), accept(), bind(), connect() or
>listen()[...]

Without reading any further (yet), that sounds like
http://www.synack.fr/project/cn_net/cn_net.html

>All proposed implementations of personal firewalls until now have made
>it rather clear that the decision-making logic should be placed in
>userspace, whilst only a small piece of code communicating with a
>userspace daemon should be placed in the kernel itself.

Well of course. You want a personal firewall that asks the user,
it is going to involve userspace. Also because that is simpler
to implement and debug.

>Most implementations started out using the LSM framework for creating a
>personal firewall, that's also the reason the whole discussion started
>out on the LSM mailing list.
>Even though this looks like a good solution there is one main problem
>with the LSM framework right now: only a single LSM module can be loaded
>and enabled at a time.

Thank the guys who removed the modular LSM interface.

>However, this was done intentionally as stacking
>multiple LSMs proved to be complex and not entirely sane.

Yes, but each LSM could decide whether it supports stacking of
another module after it (either by invoking that module or not
doing so at all).

>And yet another approach was suggested: hooking socket-related calls
>directly in net/socket.c. This would mean that the personal firewall
>code is called directly from net/socket.c and can this way work in
>process-context, without using the LSM framework.
>On the other hand this would add, besides the LSM calls that are in
>place in net/socket.c a few extra calls which might not be what we want.[...]

My opinion up to here would be to split LSM into the LSM category
{selinux, apparmor, tomoyo} and the other, new LSM category
{networking stuff}, just as a potential idea to get over the
stacking / single LSM use  issue.

>What has not been agreed on yet is whether only a way of hooking these
>calls should be made available to implementations or whether the whole
>in-kernel part should be developed together and allow implementations of
>personal firewalls in userspace only, for example using a netlink socket
>to communicate with the shared in-kernel code.

That is what cn_net should be doing, I hear. So ... hmhm *dribble*.

>Implementations using the LSM approach are TuxGuardian [0] and snet [1].
>Code implementing the last mentioned approach can be found in git over
>at [2] in the sactl-direct branch.
>
>[0] http://tuxguardian.sourceforge.net/

tuxguardian is probably regardable as obsoleted by cn_net (if it's
finished someday, or is it?) -- Samir probably knows more.

>[1] http://www.synack.fr/project/snet/snet.html
>[2] http://repo.or.cz/w/linux-2.6/sactl.git
