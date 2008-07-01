From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprinting.
Date: Tue, 01 Jul 2008 13:53:43 +0200
Message-ID: <486A1AC7.9020706@trash.net>
References: <20080701113927.GA16343@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080701113927.GA16343@2ka.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Passive OS fingerprinting iptables (xtables) allows to match incoming
> packets by different sets of SYN-packet and determine, which remote
> system is on the remote end, so you can make decisions based on OS
> type and even version at some degreee and perform various netfilter
> actions based on that knowledge.
> 
> This module compares some data (WS, MSS, options and it's order, ttl, df
> and others) from packets with SYN bit set with dynamically loaded OS
> fingerprints.

[Only some general comments without having looked at the
code in detail]

My two main objections are that this only works for TCP and
can be trivially evaded. What use cases does it have?
I'm also wondering whether this couldn't be implemented
using the u32 match.

> This version existed quite for a while in patch-o-matic(-ng), but
> suddenly was dropped and then only was updated on its own repo:
> http://tservice.net.ru/~s0mbre/old/?section=projects&item=osf
> 
> I've updated OSF to match new iptables standards (namely xtables
> support) and present new kernelspace and userspace library files in
> attach.
> 
> To setup single rule, which will drop and log all Linux incoming
> access one needs to do following steps:
> # insmod ./ipt_osf.ko
> # ./load ./pf.os /proc/sys/net/ipv4/osf
> # iptables -I INPUT -j DROP -p tcp -m osf --genre Linux --log 2 \
> --ttl 2 --connector

And I don't think it should be using connector. AFAIK we
only have a single user in the tree currently and new
stuff usually uses genetlink (which is pretty similar),
so we might be able to remove connection in the future
unless we add new users. But netfilter modules should
use nfnetlink anyway.



