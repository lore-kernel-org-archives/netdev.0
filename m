From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Thu, 12 Jan 2017 08:17:18 -0700
Message-ID: <da432a7e-63f2-c94b-9b60-aa763715b550@cumulusnetworks.com>
References: <20170106153026.24785-1-lorenzo@google.com>
 <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
 <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Erik Kline <ek@google.com>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        David Miller <davem@davemloft.net>,
        Daniel Rosenberg <drosen@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:32967 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750818AbdALPRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:17:23 -0500
Received: by mail-io0-f182.google.com with SMTP id v96so20641734ioi.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 07:17:23 -0800 (PST)
In-Reply-To: <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/9/17 7:01 PM, Lorenzo Colitti wrote:
> On Sun, Jan 8, 2017 at 1:24 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> Why not use the VRF capability then? create a VRF and assign the interface to it. End result is the same -- separate tables and the need to use a bind-to-device API to hit those routes.
> 
> Requiring that VRFs for this creates additional complexity, because
> each network now requires its own VRF. That means that the connection
> manager must create the VRF before the interface comes up and receives
> the RA.
> 
> In some cases this might not be possible. For example, consider a tun
> interface that's created by a different process such as a VPN client.
> In this case the connection manager doesn't know the interface name,
> and the VPN client doesn't know to create the VRF, so if the tun
> interface gets an RA after the tun is created but

Have you looked at adding basic l3mdev capabilities to tun? in this case just l3mdev_fib_table needs be implemented. On interface create push down a table id and set the IFF_L3MDEV_MASTER flag.
