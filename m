From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: RFC: pid "ownership" of ip config information
Date: Sun, 23 Jan 2011 13:32:53 +0100
Message-ID: <4D3C1FF5.2010607@gmail.com>
References: <1295602091.3582.1.camel@lat1>  <4D395D3C.9010308@gmail.com> <1295778271.5657.7.camel@lat1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Patrick Schaaf <netdev@bof.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58565 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab1AWMc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 07:32:58 -0500
Received: by wwa36 with SMTP id 36so3417840wwa.1
        for <netdev@vger.kernel.org>; Sun, 23 Jan 2011 04:32:57 -0800 (PST)
In-Reply-To: <1295778271.5657.7.camel@lat1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/01/2011 11:24, Patrick Schaaf a =C3=A9crit :
> On Fri, 2011-01-21 at 11:17 +0100, Nicolas de Peslo=C3=BCan wrote:
>> Le 21/01/2011 10:28, Patrick Schaaf a =C3=A9crit :
>>> The alternative to such a feature, would be to have an additional
>>> monitoring process, which would watch the PID somehow, and need to
>>> be configured to know what to withdraw when it dies.
>
>> There exists some user space clustering system that should provide t=
he same functionalities. Did you
>> had a look at http://www.linux-ha.org/ ?
>
> Those would be the more complex instances of "an additional monitorin=
g
> process", right?
 >
> What happens when heartbeat is "kill -9"ed? Assume that I want to avo=
id
> STOMITH like approaches.
 >
> My proposal could be _used_ by such complex clustering managers, too.
>
> Or, did I overlook there a kernel based solution to "withdraw IP conf=
ig
> when processes die"?
 >
> Can you provide a direct link on linux-ha?

Do you consider "withdraw IP config" the only feature that is needed wh=
en a process die ? Or shall=20
we instead design a more generic framework to run a command or call a s=
ystem call when a process die=20
? /sbin/init is probably already doing something similar. Arguably, eve=
n init mail hang...

If your point is to provide a safety net for very sick but not really d=
ied node, then, no userland=20
system would help. As such, I agree with you that an automatic withdraw=
 of IP config might help.=20
However, how would you protect against a simple never ending loop in th=
e process or against very=20
slow process due to high load on the node? You probably also need to gu=
ard against process not=20
reading the network receive queue anymore.

This might end up with some sort of local heart beating monitoring of u=
serland process, in the=20
kernel, and I'm not sure if someone would support this.

And whatever you do locally to a node to ensure proper operation, you n=
eed a way to also check for=20
proper operation from outside of the node. A STOMITH system is always r=
equired, in order to kill a=20
totally mad node. Even the kernel may become mad.

	Nicolas.
