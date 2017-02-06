From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: Pseudo-Interface is returning wrong mac address
Date: Mon, 6 Feb 2017 13:18:42 +0100
Message-ID: <20170206121842.GA7008@unicorn.suse.cz>
References: <CAOfznLKvVVsy7NGiZ3qECZLXgnTmmKahrO3ZbdprvZK4p8s4iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shaaa <shaolinfinest@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55903 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752087AbdBFMSo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 07:18:44 -0500
Content-Disposition: inline
In-Reply-To: <CAOfznLKvVVsy7NGiZ3qECZLXgnTmmKahrO3ZbdprvZK4p8s4iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2017 at 05:56:31AM +0000, Shaaa wrote:
> 
> I am trying to setup macvlans on a centos7 box. The plan is to have
> 10.1.1.1/24 on the *main* interface, and then a 10.1.1.10/32 on a
> macvlan interface. Output below:
> 
> 2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
> state UP qlen 1000
>     link/ether 01:0d:26:9d:cd:16 brd ff:ff:ff:ff:ff:ff
>     inet 10.1.1.1/24 brd 10.1.1.1.255 scope global ens33
>        valid_lft forever preferred_lft forever
> 8: peth1@ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
> noqueue state UNKNOWN qlen 1000
>     link/ether 02:1a:11:ed:22:ac brd ff:ff:ff:ff:ff:ff
>     inet 10.1.1.10/32 scope global peth1
>        valid_lft forever preferred_lft forever
> 
> 
> The problem is whenever I do arping 10.1.1.10 from another another
> host on the network, the mac address of ens33 is returned as opposed
> to peth0. I am not entirely sure whether this is intended behaviour or
> whether it is a bug, but from what I have gathered, the mac of peth0
> should be returned.

Yes, it's intentional and it's not specific to macvlan; you can observe
similar effect whenever you connect two interfaces to the same segment.
By default, linux kernel responds to an ARP query for any local address
on any interface (sometimes called "ARP flux"). This behaviour can be
changed via sysctl, see arp_ignore and arp_filter in
Documentation/networking/ip-sysctl.txt

Michal Kubecek
