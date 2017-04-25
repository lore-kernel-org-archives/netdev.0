From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Tue, 25 Apr 2017 08:27:41 -0700
Message-ID: <20170425082741.59428876@xeon-e3>
References: <58F9FD64.80506@aoifes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rafa Corvillo <rafael.corvillo@aoifes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:35939 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948960AbdDYP1y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:27:54 -0400
Received: by mail-it0-f45.google.com with SMTP id g66so20956884ite.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 08:27:54 -0700 (PDT)
In-Reply-To: <58F9FD64.80506@aoifes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Apr 2017 14:39:00 +0200
Rafa Corvillo <rafael.corvillo@aoifes.com> wrote:

> We are working in an ARMv7 embedded system running kernel 4.9 (LEDE build).
> It is an imx6 board with 2 ethernet interfaces. One of them is connected to
> a Marvell switch.
> 
> The schema of the system is the following:
> 
>   +-------------------+ eth0
>   |                   +--+
>   |                   |  |
>   | Embedded system   +--+
>   |                   |
>   |      ARMv7        |
>   |                   | Marvell 88E8057(sky2) +-------------+
>   |                   +--+ +--+             +--+ eth1
>   |                   |  +---------------------+ |             |  +------+
>   |                   +--+      CPU port       +--+ mv88e6176  +--+
>   +------+--+---------+ |             |
> emulated|  | |             |
> GPIO    +--+ +--+             +--+ eth2
> MDIO      +-----------------------------------+ |             |  +------+
>                                MDIO +--+             +--+
> +-------------+
> 
> There is a bridge (br-lan) which includes eth0/eth1/eth2
> 
> If I connect the eth1/eth2, the link is up and I can do ping through it. 
> But, once
> I start sending a heavy traffic load the link fails and the kernel sends the
> following messages:
> 
> [   48.557140] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
> length 1518
> [   48.564964] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
> length 1518
> [   48.572110] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
> length 1518
> [   48.579263] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
> length 1518
> [   48.586417] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
> length 1518
> [   48.593573] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
> length 1518
> [   48.600718] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
> length 1518
> [   54.877567] net_ratelimit: 6 callbacks suppressed
> [   54.882293] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
> length 1518
> [   61.413552] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010 
> length 1518

The status error bits are in sky2.h
0x5f20010 is
     05f2 frame length => 1522 
     0010 Too long err

That means the packet was longer than the configured MTU.
You are probably getting packets with VLAN tag but have not configured
a VLAN.
