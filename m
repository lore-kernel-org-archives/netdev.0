From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 action/policer question
Date: Wed, 17 Jun 2009 21:43:18 +0200
Message-ID: <20090617194318.GA2747@ami.dom.local>
References: <20090615111927.GA12316@ff.dom.local> <20090617061458.GA9412@ff.dom.local> <20090617062846.GA9764@ff.dom.local> <200906171201.37727.denys@visp.net.lb> <20090617092626.GA11005@ff.dom.local> <1245244194.4025.21.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Andreas Henriksson <andreas@fatal.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f212.google.com ([209.85.220.212]:38956 "EHLO
	mail-fx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031AbZFQTny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 15:43:54 -0400
Received: by fxm8 with SMTP id 8so585400fxm.37
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2009 12:43:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1245244194.4025.21.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2009 at 09:09:54AM -0400, jamal wrote:
> On Wed, 2009-06-17 at 09:26 +0000, Jarek Poplawski wrote:
> > On Wed, Jun 17, 2009 at 12:01:37PM +0300, Denys Fedoryschenko wrote:
> > > On Wednesday 17 June 2009 09:28:46 Jarek Poplawski wrote:
> > > 
> > > > >
> > > > > I confirm I can't get 'action ipt -j MARK' working on debian lenny
> > > > > (stable) with distro's iptables/tc. I'm not able to compile tc from
> > > > > vanilla sources properly either - configure fails 3 IPT tests. (I
> > > > > admit I can miss setting some (undocumented?) config variables.) So,
> > > > > with or without debian, IMHO iproute2 needs some updates for iptables
> > > > > 1.4.2, 1.4.3, and maybe even 1.4.4 now.
> > > >
> > > > OOPS! I _can_ configure it for 1.4.2 yet (so it's only about >= 1.4.3).
> > > >
> 
> Something like that.
> It works fine with iptables 1.4.2 for Lenny on my laptop. 

You mean Lenny with not Lenny's iproute2, I guess. Does 'works fine'
include 'action ipt -j LOG'? Anyway, let's say you're right here, and
it's "Lenny's" problem.

> It should work fine for the release after Lenny for 1.4.3 once
> the debian maintainers pick up the latest iproute2.

Why do you think so? I've tried it with current (git) iproute2 and
iptables 1.4.3.2 (Debian include files are eq. to vanilla), and here
is the configure output:

TC schedulers
 ATM    no
 IPT    /tmp/ipttest.c:6: error: variable 'afinfo' has initializer but incomplete type
/tmp/ipttest.c:7: error: unknown field 'libprefix' specified in initializer
/tmp/ipttest.c:7: warning: excess elements in struct initializer
/tmp/ipttest.c:7: warning: (near initialization for 'afinfo')
/tmp/ipttest.c:10: warning: 'enum exittype' declared inside parameter list
/tmp/ipttest.c:10: warning: its scope is only this definition or declaration, which is probably not what you wa
/tmp/ipttest.c:10: error: parameter 1 ('status') has incomplete type
failed test 2
In file included from /tmp/ipttest.c:2:
/home/info/src/git/iproute2/include/xt-internal.h:36: error: redefinition of 'struct xtables_rule_match'
/home/info/src/git/iproute2/include/xt-internal.h:50: error: conflicting types for 'xtables_insmod'
/usr/local/include/xtables.h:215: error: previous declaration of 'xtables_insmod' was here
/tmp/ipttest.c:11: warning: 'enum exittype' declared inside parameter list
/tmp/ipttest.c:11: warning: its scope is only this definition or declaration, which is probably not what you wa
/tmp/ipttest.c:11: error: parameter 1 ('status') has incomplete type
failed test 3 using iptables

After this I get tc compiled, but it gives misleading error messages
later (just like distro's tc).
 
> For other Distros: it should work fine if they have iptables 1.4.2/3.

The latest official version 1.4.3.2 (until today) doesn't work fine
for Debian & me (maybe we're special...).

> iptables 1.4.4 is not mainstream; i need to add a new test to detect
> it once it is mainstream (actually i could do it before it becomes
> mainstream and still make it backwards compatible).
> I contributed about 10 patches to iptables to try and make sure it
> doesnt break again ;-> Hopefully my efforts will be rewarded
> (or as the saying goes perhaps "no good deeds go unpunished");->
> I have confidence the iptables people are more aware of the API
> breakages now than before - so very low probability it will break
> post iptables 1.4.4.

I don't understand why you're defending those ugly destroyers of your
outstanding work?! (Did they threaten you? Don't worry - they're far
away in Australia... ;-)

> For versions lower than iptables 1.4.1 I think i will give up instead of
> making it compatible all the way back there.
> I use debian exclusively (and these days all my machines are lenny) so
> those are the only machines i test on.

As a matter of fact, after I couldn't even check Pawel's simple
examples neither on debian testing nor stable I was very near of
looking for another the distro...

> 
> > > I check that, and found again many small changes in iptables, that screwed ipt 
> > > action in iproute2.
> > > 
> > > I really think it doesn't worth to put too much efforts fixing it, with each 
> > > new release iptables. I switch to other way of "tagging" packets, skbedit, 
> > > and it seems it is also faster.
> > 
> > If it were only about -j MARK you're 100% right. Other targets could
> > be harder to replace - if they work of course ;-) Of course it's all
> > up to Jamal, but on the other hand I'm really confused debian stable
> > (or even testing) maintains such a broken state without any notice
> > or simply disabling it to save people's time.
> > 
> 
> It should work with others as well - if it doesnt theres a bug
> somewhere. I dont have time this week - but if theres a script that is
> supposed to work that doesnt work, please send it to me and i will look
> into it.

Just similarly to Pawel:
tc qdisc add dev lo root handle 1: htb
tc filter add dev lo parent 1: proto ip pref 5 u32 match u32 0 0 action ipt -j LOG

Cheers,
Jarek P.
