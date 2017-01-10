From: Mason <slash.tmp@free.fr>
Subject: Re: Setting link down hangs the kernel
Date: Tue, 10 Jan 2017 16:28:05 +0100
Message-ID: <b478607d-cb69-0efc-5a8c-9b7a54b88d68@free.fr>
References: <3ac03634-02fa-6acd-479d-fc475fc45736@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Thomas Gambier <thomas_gambier@sigmadesigns.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:47557 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754789AbdAJP2U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 10:28:20 -0500
In-Reply-To: <3ac03634-02fa-6acd-479d-fc475fc45736@free.fr>
Content-Language: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2017 15:36, Mason wrote:

> I'm using kernel v4.9 on a [new] dev board.
> I built a small kernel + rootfs with buildroot 2016.11.1
> eth0 is driven by drivers/net/ethernet/aurora/nb8800.c
> 
> After booting, I just run udhcpc (busybox version)
> Then I set the link down, and the kernel hangs.

So far, I've been unable to reproduce this issue on an older
smp8758 dev board.

# while true
> do
> ip link set dev eth0 down
> sleep 3
> ip link set dev eth0 up
> sleep 3
> let "++XX"
> echo $XX
> done

The output is strange nonetheless:

1
2
3
4
5
[  179.002757] nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
6
7
[  192.538648] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
8
9
10
11
12
[  222.284936] nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
13
14
^C
# [  235.800851] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx


A) I would expect a "Link is Up" message for every "link up" command.
I get only 4 messages for 14 commands. Is that expected?

B) Twice, the PHY was only able to negotiate 100 Mbps, although the
peer supports 1 Gbps. What could cause this?

Regards.
