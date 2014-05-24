From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Sat, 24 May 2014 11:13:45 -0400
Message-ID: <5380B729.5080101@mojatatu.com>
References: <6zlhtsvnqp.fsf@southpole.se>	<53808957.7020906@mojatatu.com> <CAFLxGvx-6F3OqSBjSCBnm5b+m_NingSsbO2qaP7K7TtJghF5LQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TmllbHMgTcO2bGxlcg==?= <nisse@southpole.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jonas Bonn <jonas@southpole.se>
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:57955 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbaEXPNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 11:13:49 -0400
Received: by mail-ie0-f172.google.com with SMTP id tp5so6214672ieb.17
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 08:13:47 -0700 (PDT)
In-Reply-To: <CAFLxGvx-6F3OqSBjSCBnm5b+m_NingSsbO2qaP7K7TtJghF5LQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/14 10:44, Richard Weinberger wrote:

> How to use this?
> My tc's manpage does not know anything about nat.
>

Start writing one and i will help.

> Maybe I'm mistaken but IIRC all non-netfilter nat code has been removed.
>

This is stateless nat nothing to do with netfilter (much more 
efficient). Here's some documentation for you ;->
----
hadi@jhs-1:~$ $TC filter add $DEV parent ffff: protocol ip u32 match ip 
dport 8080 0xffff flowid 1:1 action nat help
Illegal nat construct (help)
Usage: ... nat NAT
NAT := DIRECTION OLD NEW
DIRECTION := { ingress | egress }
OLD := PREFIX
NEW := ADDRESS
bad action parsing
parse_action: bad value (2:nat)!
Illegal "action"
-----

Google will give you more examples, but here's one:

Lets add a rule on the public facing bridge:

hadi@jhs-1:~$ $TC filter add dev virb0 parent ffff: protocol ip u32 
match ip dport 8080 0xffff flowid 1:1 action nat ingress 
192.168.10.15/32 10.0.0.15/32


now display it:
hadi@jhs-1:~$ $TC -s filter ls dev virbr0 parent ffff: protocol ip
filter pref 49152 u32
filter pref 49152 u32 fh 800: ht divisor 1
filter pref 49152 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1
   match 00001f90/0000ffff at 20
	action order 1:  nat ingress 192.168.10.15/32 10.0.0.15 pass
         installed 96 sec used 96 sec	Action statistics:
	  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	  backlog 0b 0p requeues 0

You will need to add a reverse translation for internal->external

etc

cheers,
jamal
