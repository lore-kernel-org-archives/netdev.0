From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: block network access for certain users/groups
Date: Wed, 25 Aug 2010 20:58:14 +0900
Message-ID: <201008252058.DDE12933.FOLOHQSJFFOMtV@I-love.SAKURA.ne.jp>
References: <AANLkTin8w74SAe67ZPqPE0Q=0fPpZOHnTCnjAT+AduCY@mail.gmail.com>
	<AANLkTikru-pmMAnS-dqjYT7xJC_X21rVNBpjg_2LDmWB@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: estellnb@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikru-pmMAnS-dqjYT7xJC_X21rVNBpjg_2LDmWB@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Elmar Stellnberger wrote:
> Please answer my question:
> It has not been answered, yet.
> Thanks for hints like whether to use DROP or REJECT but please answer
> my question!
> 
> I wanna be pointed on how to implement a per user package selection.

A package sounds something like application. What you want to do is
"packet selection" (like iptables) rather than "package selection"
(like rpm/dpkg). Please "sed -e 's/package/packet/g'"...

> Something similar pretends to be already implemented if you view the
> man page, but
> it is only implemented for outgoing packages and it even does not work
> correctly
> (blocking outgoing ICMP-ping requests but with lynx you can happily
> view localhost:631
> though the rule is on top and applies to any kind of package (raw,
> tcp, udp)). We have
> already checked this thouroughly.

Regarding incoming packets, it is impossible to perform packet filtering based
on uid/gid because the uid/gid who picks up the packet is not known until a
user issues accept()/recvmsg(). The socket's owner may change between the
moment iptables inspected the packet and the moment a user picks up the packet
because it is possible to send the socket's file descriptor via Unix domain
socket or call setuid()/setgid().

> I need to block network access for certain users/groups, fully:
> 
> iptables -A mychain -m owner --gid-owner blockedusergroup -j REJECT
> 
> ...drops ping packages in the output chain but lets my user happily
> connect to localhost:631 or any other http address. In deed the rule
> above is therefore pretty useless.
> 
> I need to block ALL incoming and outgoing packages for a certain user/group.
> At the moment there is only insufficient blocking for outgoing
> packages available.
> 
> Can you help me?
> What will I have to do to implement network access restrictions on a
> per user/group basis?

The only way that makes possible to block access by blockedusergroup is to
insert hooks like http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/net/ipv4/udp.c#L1144
and http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/net/socket.c#L1504 .
But such hooks are not acceptable for upstream kernel. Please see
http://kerneltrap.org/mailarchive/linux-netdev/2010/7/21/6281491 for
discussion on these hooks.

> Logging such packages is already possible. Why is blocking them not?
> 
> ... and yes I have already checked the whole iptables -L -v.
> The rule is there and would have been supposed to work.
> 
> Yours,
> Elmar Stellnberger
