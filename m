From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: phy link status not stable
Date: Tue, 16 Sep 2014 10:09:36 -0700
Message-ID: <CAGVrzcZ4BPJ-6t81vevb2g7jMqRmeCnGfEOhZA2gLO7qawZvPg@mail.gmail.com>
References: <541864D0.7080803@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:64345 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaIPRKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 13:10:17 -0400
Received: by mail-ig0-f173.google.com with SMTP id l13so5960725iga.12
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 10:10:16 -0700 (PDT)
In-Reply-To: <541864D0.7080803@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-09-16 9:26 GMT-07:00 Mugunthan V N <mugunthanvnm@ti.com>:
> Hi
>
> While doing ifdown/ifup test, phy link up status is very much delayed
> and also link up/down comes alternatively without physical link changes
> which leads to ifup failure. in v3.12 internal tree there is no failure.
> Pasting the logs below.

Assuming your driver calls phy_start() and phy_stop() from the
ndo_open() resp. ndo_stop() functions, these function calls are not
synchronous, as in they do not wait for the link to go UP resp. DOWN
before returning. The PHY state machine gets programmed to a new state
from phy_start() resp. phy_stop() and the next workqueue execution
will proceed with an actual state change.

>
> root@am437x-evm:~# ifup eth0
> [  652.633204] net eth0: initializing cpsw version 1.15 (0)
> [  652.717428] net eth0: phy found : id is : 0x221622
> udhcpc (v1.20.2) started
> Sending discover...
> Sending discover...
> [  658.717859] cpsw 4a100000.ethernet eth0: Link is Up - 1Gbps/Full -
> flow control rx/tx
> Sending discover...
> [  660.717894] cpsw 4a100000.ethernet eth0: Link is Down
> [  661.717937] cpsw 4a100000.ethernet eth0: Link is Up - 1Gbps/Full -
> flow control rx/tx
> No lease, failing
> root@am437x-evm:~# udhcpc
> udhcpc (v1.20.2) started
> Sending discover...
> Sending select for 172.24.190.6...
> Lease of 172.24.190.6 obtained, lease time 3600
> /etc/udhcpc.d/50default: Adding DNS 192.0.2.2
> /etc/udhcpc.d/50default: Adding DNS 192.0.2.3
> root@am437x-evm:~#
>
> Is this a known issue or any pointers where to look for clues?

This is not a known issue AFAICT, is the link really flapping? Not
sure if [1] could explain what you are seeing?

[1]: http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=95e8b10393f88a0db88d97e9d1953f01c854315a
could ex

>
> Setup: TI-AM437x EVM
> Phy: Micrel KSZ9031 Gigabit PHY
>
> Thanks,
> Mugunthan V N
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
