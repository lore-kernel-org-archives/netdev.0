From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: iproute2: Run over all netns
Date: Mon, 05 Jan 2015 17:40:51 +0100
Message-ID: <54AABE93.2010602@6wind.com>
References: <20150105122333.GA6646@angus-think.wlc.globallogic.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33039 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806AbbAEQkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 11:40:55 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so3674994wiw.4
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 08:40:53 -0800 (PST)
In-Reply-To: <20150105122333.GA6646@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2015 13:23, Vadim Kochan a =E9crit :
> Hi All,
>
> I have some piece of code which allow 'ip cmd'
> on each netns, I found it useful for getting some info
> from all the netns in one shot, BUT I faced with one issue
> which mostly related to the user interface design. The problem
> is that it would be good to print netns name only when
> user uses "show" command, but not for updating/adding (IMHO),
> but its hard to find the good way to implement this.
>
> To run each netns the 'ip -net all CMD ...' construction can be used.
>
> I see the following options for this:
>
> #1 Add additional option ( -N ? ) for show netns label on each execut=
ing of CMD:
>
>      # ip -net all -N link
>
>      [test_net]
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>
>      [home0]
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>
>      [lan0]
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>
>      [wan0]
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>      2: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN gro=
up default
>          link/ether 16:f7:cb:b6:7a:8e brd ff:ff:ff:ff:ff:ff
>
>      [vnet0]
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>
>
>      and w/o:
>
>      # ip -net all link
>
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>      2: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN gro=
up default
>          link/ether 16:f7:cb:b6:7a:8e brd ff:ff:ff:ff:ff:ff
>
>      1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
>          link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>
>      the last one is not so useful right ?
>
> #2 Prints netns name by default if "-net all" was specified
> (add option to prevent this ?), so it will be printed even on the
> add/del/change commands ...
I vote for this one (I don't think the option to prevent it is needed, =
it's
better to be explicit).

>
>      # ip -net all link add ...
>
>      [home0]
>      [lan0]
>      [wan0]
>      [vnet0]
>
>      but does it really useless to see that it will shows all the net=
ns
>      on which cmd has been ran ?
I tend to say yes (another process may add/remove a netns in the same t=
ime).


Regards,
Nicolas
