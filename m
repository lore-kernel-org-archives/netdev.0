From: =?iso-8859-1?q?T=F6r=F6k_Edwin?= <edwin@gurde.com>
Subject: Re: [Fireflier-devel] Re: [PATCH][RFC] Security marking
Date: Sun, 23 Apr 2006 21:57:59 +0300
Message-ID: <200604232157.59758.edwin@gurde.com>
References: <20060417184053.6D618378FD@localhost.localdomain> <Pine.LNX.4.64.0604172051510.20174@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	fireflier-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216.255.188.82-custblock.intercage.com ([216.255.188.82]:17618
	"EHLO main.astronetworks.net") by vger.kernel.org with ESMTP
	id S1751448AbWDWT7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 15:59:25 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0604172051510.20174@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 18 April 2006 04:01, James Morris wrote:
> On Mon, 17 Apr 2006, edwin@gurde.com wrote:
> > Secmark, or skfilter is exactly what fireflier needs to solve the shared
> > socket issue. Thanks for working on this. If this gets integrated in
> > mainline, fireflier LSM will be dropped.
>
> I think you probably need skfilter as a standalone option.
I'll use skfilter then.
>
> > Is it possible to have an SELinux policy that reinjects the packets if
> > didn't match any rules? I.e. if a program that listens on port 80 doesn't
> > have access to the packet, (because it doesn't have the proper domain,)
> > and the SELinux won't allow the program to read the packet: is it
> > possible to reinject this packet in the netfilter chain, instead of
> > dropping it?
> >
> > This would allow creating rules interactively (fireflier).
>
> This could be done with nfqueue, modular policy and a pretty simple tool.
How do I determine if the policy needs to be changed? I.e. how do I determine 
if the packet would be dropped? You say packets are silently dropped, won't 
they generate an avc denied at least? (at least the first time?)
Once I determine that, I understand what you are saying: 
catch the packet with a nfqueue target, and write a proper "allow  my_t 
my_packet_t:packet { recv }" to a modular policy .te file, build that as 
a .pp, and load it using semodule (or libsemanage).
> > P.S.: Where can I get the full secmark patches, so I can test them to see
> > if they really fit my needs? Do you have an estimate timeline for
> > mainline integration? (in terms of n weeks, m months)
>
> The rest of the secmark related patches don't exist yet, I posted the core
> changes needed, and the others will be SELinux-specific.  Mainline
> integration would hopefully be 2.6.18, if it all works out ok.
Sounds good.
>
>
> If you're looking for skfilter:
> http://people.redhat.com/jmorris/selinux/skfilter/
Thanks, I know , I tested them already.
>
> Patrick McHardy has some ideas on resolving some of the skfilter issues.
Patrick what is the status of solving the skfilter issues? Can I help with 
testing patches,  etc.?

On Monday 20 February 2006 18:42, Patrick McHardy wrote:
> Confirmation of conntrack entries. They shouldn't be confirmed before
> packets have passed the socket hooks. This is the tricky part because
> we don't know if packets will be delivered to a raw socket or not
> when calling the regular LOCAL_IN hook.
> The only way to solve this 
> seems to be to use the socket hooks for all incoming packets, that
> way we can defer confirmation unconditionally.
Are there any problems with using socket hooks for all packets?
> The nicest way would 
> be to just move the regular LOCAL_IN hook to the socket hooks, but
> this doesn't work with SNAT in LOCAL_IN because the socket lookup
> needs the already NATed address.
Move just the non SNAT part of LOCAL_IN to socket hooks?(does this make 
sense?)


As you can see at http://fireflier.isgeeky.com/wiki/Ipt_fireflier_test, 
skfilter is working, although my test case was a very simple one. 
Could you provide a simple testcase where skfilter is not working right 
(conntrack...), so that I can test it too?

I applied only the ipv4 iptables related patches , there were a few failures 
due to the move to x_tables, but I think I solved them correctly. So here are 
the patch I actually applied: 
http://edwintorok.googlepages.com/linux-2.6.16.1-skfilter.patch, let me know 
if there is something wrong there.


P.S.: Fireflier will use SELinux for labeling processes (and sockets), and 
skfilter to do the actual filtering

Cheers,
Edwin
