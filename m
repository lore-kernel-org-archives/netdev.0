From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: RFC: pid "ownership" of ip config information
Date: Fri, 21 Jan 2011 11:17:32 +0100
Message-ID: <4D395D3C.9010308@gmail.com>
References: <1295602091.3582.1.camel@lat1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Patrick Schaaf <netdev@bof.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41767 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405Ab1AUKRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 05:17:37 -0500
Received: by wyb28 with SMTP id 28so1629248wyb.19
        for <netdev@vger.kernel.org>; Fri, 21 Jan 2011 02:17:36 -0800 (PST)
In-Reply-To: <1295602091.3582.1.camel@lat1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/01/2011 10:28, Patrick Schaaf a =C3=A9crit :
> Dear netdev,
>
> I want to solicit comments on a feature enhancement that occured
> to me recently.
>
> Feature:
>
> - For "ip addr add", "ip route add", "ip rule add", and maybe "ip lin=
k
> add",
>    implement an option 'pid XXXXX' to specify a PID
> - if that PID is not currently existing, fail the operation
> - if, at a later time, that PID dies, automatically remove the
> configuration,
>    as if a corresponding "ip ... del" would have been given
>
> The feature would be useful in any kind of "IP takeover" scenario.
>
> I'm concretely working on deployment of keepalived (VRRP address
> takeover) and memcachedb (address takeover after berkeley DB master
> selection).
>
> It would also apply to all kinds of routing daemons (zebra, quagga...=
).
>
> In all these cases, for as long as the process is working normally,
> it can trigger the relevant address withdrawal, but when the process
> dies unexpectedly (oom killer or whatever), addresses are left
> configured,
> while a partner on another host might take them over, resulting in
> actively duplicate IPs and the application breaking.
>
> The alternative to such a feature, would be to have an additional
> monitoring process, which would watch the PID somehow, and need to
> be configured to know what to withdraw when it dies.
>
> Before I go ahead and try to implement that, I would like to have
> some feedback regarding the idea
>
> - has it been discussed before?
> - would it be accepted by the relevant maintainers?
> - did I overlook alternative solutions to the problem?

There exists some user space clustering system that should provide the =
same functionalities. Did you=20
had a look at http://www.linux-ha.org/ ?

> best regards
>    Patrick
