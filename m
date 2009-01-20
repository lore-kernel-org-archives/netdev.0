From: Samir Bellabes <sam@synack.fr>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Tue, 20 Jan 2009 21:15:53 +0100
Message-ID: <m2prih3f9i.fsf@ssh.synack.fr>
References: <1232473719.24943.102.camel@sp-laptop3.sp-local>
	<alpine.LSU.2.00.0901201916340.516@fbirervta.pbzchgretzou.qr>
	<1232477780.24943.116.camel@sp-laptop3.sp-local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Stephan Peijnik <stephan@peijnik.at>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1232477780.24943.116.camel@sp-laptop3.sp-local> (Stephan
	Peijnik's message of "Tue, 20 Jan 2009 19:56:20 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephan Peijnik <stephan@peijnik.at> writes:

> On Tue, 2009-01-20 at 19:24 +0100, Jan Engelhardt wrote:
>> On Tuesday 2009-01-20 18:48, Stephan Peijnik wrote:
>> >
>> >A personal firewall should implement per-application mandatory access
>> >control for sockets. In short this means that such a program decides
>> >every time a call to either socket(), accept(), bind(), connect() or
>> >listen()[...]
>> 
>> Without reading any further (yet), that sounds like
>> http://www.synack.fr/project/cn_net/cn_net.html

I have updated cn_net, for supporting libnl and having a library in
userspace.
http://www.synack.fr/project/snet/snet.html
but you are perfectly right, this is exactly what I implemented.

> Yes, it does, and it's exactly that. However, as a LSM it can only be
> used whilst no other LSM is enabled. 
> Samir Bellabes has been involved in the discussion at
> linux-security-module too.
> Even though I like the implementation personally I'm unsure about
> whether this should be dubbed "the one" way to do this or whether there
> should be an API for alternative implementations.

be carefull, you are mixing 2 distincts questions in fact :

1. how to have differents security models in the kernel, dealing with
   the LSM hooks ?

2. how to build a 'personnal firewall', based on syscall applications ?

I have a answer for the second question, it's snet, as it's the simplest
way for the kernel to deal with this problem.

For the first question, you can build a personnal firewall with LSM
hooks, if, at compilation time, you don't choose other LSM
solutions. that's how I'm using snet.
But what you are asking is to have multiple security models at the same
time, with some kind of priority.
I don't know if it's ok or not, but what I'm sure is that snet will use
LSM hooks or your new framework without any problems in fact, as you are
going to make some kind of wrapper on the members of the struct
security_operations.

>> >And yet another approach was suggested: hooking socket-related calls
>> >directly in net/socket.c. This would mean that the personal firewall
>> >code is called directly from net/socket.c and can this way work in
>> >process-context, without using the LSM framework.
>> >On the other hand this would add, besides the LSM calls that are in
>> >place in net/socket.c a few extra calls which might not be what we want.[...]
>> 
>> My opinion up to here would be to split LSM into the LSM category
>> {selinux, apparmor, tomoyo} and the other, new LSM category
>> {networking stuff}, just as a potential idea to get over the
>> stacking / single LSM use  issue.

Indeed I thought about that when writing snet.

> The problem here is that all of your three examples do use the LSM
> networking hooks too. If two functions are to be called from the LSM
> core (ie. the generic LSM one and the networking-LSM one) we get pretty
> much the same problem back as if we multiple generic LSMs enabled.

I agree that can be issue, but this as nothing to do with implementing a
personnal firewall. you see, there are 2 questions beside your
thought.

You can ask yourself about having the same kind of subsystem for
syscalls related to filesystem (open, read, write, ..).
So you can build your own security model by picking-up a subsystem A
for networking part, and a subsystem X for the filesystem part.
in this way, you can let people writing differents models for networking,
or filesystem, and so on.

I won't fight for this idea, because I'm not sure it's right or not. I
just thought about when developping snet, because I wanted to plug the
same kind of code as snet, dealing with others security hooks (as
filesystem, ..), to complete the job of snet.
But I personnaly have no shame to said that, in the 'security' point of
view, I don't known if this model means something.

>> >Implementations using the LSM approach are TuxGuardian [0] and snet [1].
>> >Code implementing the last mentioned approach can be found in git over
>> >at [2] in the sactl-direct branch.
>> >
>> >[0] http://tuxguardian.sourceforge.net/
>> 
>> tuxguardian is probably regardable as obsoleted by cn_net (if it's
>> finished someday, or is it?) -- Samir probably knows more.

concerns about tuxguardian:
 - it is using sock_sendmsg/sock_recvmsg for userspace communication.
 - there is no timeout when waiting for userspace decision on the
   syscall
 - it is dealing only with members .socket_create and .socket_listen
   from the struct security_operations

> The tuxguardian developers seem to be interested in picking up
> development again and as I wrote Samir has already been involved in this
> discussion.
>
> -- Stephan

sam
