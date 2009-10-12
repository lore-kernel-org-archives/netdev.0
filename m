From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet packets in ifb?!
Date: Tue, 13 Oct 2009 01:44:04 +0300
Message-ID: <200910130144.04910.denys@visp.net.lb>
References: <200910121143.39924.denys@visp.net.lb> <200910130054.23237.denys@visp.net.lb> <1255385250.5406.43.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:35087 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756959AbZJLWqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 18:46:08 -0400
In-Reply-To: <1255385250.5406.43.camel@dogo.mojatatu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 October 2009 01:07:30 jamal wrote:
> On Tue, 2009-10-13 at 00:54 +0300, Denys Fedoryschenko wrote:
> > I don't have problem with existing behaviour, since i am using other way
> > of shaping, for my case using pktedit to assign priority to SKB and
> > shaping by it.
>
> I am dissapointed Denys, you dont like ipt?;->
It kills me :-) Each new version it doesn't work and i notice, i'm almost one  
who use it :-) Probably i should wait till netfilter API and iptables 
conversion will stabilize somehow.

Plus skbedit in some cases will be faster, if i eliminate iptables, unloading 
modules even, basic filtering can be done by iproute2 too, i won't have 
netfilter locks that make things slow on SMP (at least what i heard here and 
what oprofile shows, that MARK was small CPU hog to compare with skbedit).

I am happily running 2k pppoe users on Quad Core CPU/on supercheap r8169
(better nic not available here) with skbedit and flow classifier. It can do 
more even, i think.
After switching to skbedit things improve a lot (before 1k users was near max)

>
> > But generally problem is was told by one of russian developers who is
> > working on firmware for few models of broadband routers, he asked to help
> > on ISP forum, and if possible to explain this to someone who can give
> > advice, and maybe tell that probably there is a bug.
>
> [..]
>
> > If it is not, then just simple question, it will work reliably if i just
> > use u32 filter with offset on ifb?
>
> Yes, of course you can if you add offset sizeof pppoe header.
> But:
> It looks like there is a genuine need for this feature.
>
> The challenge is: I am trying to be generic across devices of many
> different types (ethernet, atm, virtual etc) at many entry points,
> ingress, egress local, forwarding etc.
> This feature that this person would need will only work if you _know_
> what you are doing; i.e in this case, I can very easily turn it off with
> a simple command - but the user must know that they do this on ingress
> side. I can cook a very quick patch for kernel and user space - you
> think this user can test it?
I can test even, even if he won't.

As i understand, for pppoe case, he can just skip offset for ethernet and 
pppoe header, and he can filter by ip, or not?
Current way is maybe better, cause someone who want to count everything with 
ethernet and pppoe headers - can, and who want without - also can (by setting 
offset , just a bit more difficult.

Like 
/sbin/tc filter add dev eth1 protocol 0x8864  parent 2:0 prio 1 u32 \
match u32 0x$IPREMOTE_HEX 0xffffffff at 24 flowid 2:$ID
(found in LARTC)


>
> cheers,
> jamal


