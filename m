From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Tue, 10 Jan 2017 11:01:44 +0900
Message-ID: <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com>
References: <20170106153026.24785-1-lorenzo@google.com> <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Erik Kline <ek@google.com>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        David Miller <davem@davemloft.net>,
        Daniel Rosenberg <drosen@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:36797 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764560AbdAJCCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 21:02:06 -0500
Received: by mail-vk0-f46.google.com with SMTP id t8so18710530vke.3
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 18:02:06 -0800 (PST)
In-Reply-To: <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 8, 2017 at 1:24 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Why not use the VRF capability then? create a VRF and assign the interface to it. End result is the same -- separate tables and the need to use a bind-to-device API to hit those routes.

Requiring that VRFs for this creates additional complexity, because
each network now requires its own VRF. That means that the connection
manager must create the VRF before the interface comes up and receives
the RA.

In some cases this might not be possible. For example, consider a tun
interface that's created by a different process such as a VPN client.
In this case the connection manager doesn't know the interface name,
and the VPN client doesn't know to create the VRF, so if the tun
interface gets an RA after the tun is created but

As others have mentioned, IPv6 on VRFs in client mode is also not
necessarily well-supported at the moment, and I don't know how long it
would take for it to be (assuming it can be made to work properly in
client mode without breaking the primary use cases for VRFs).
