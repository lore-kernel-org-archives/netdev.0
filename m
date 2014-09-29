From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Mon, 29 Sep 2014 13:13:47 -0700
Message-ID: <CAEP_g=-bGgu8QqtvcEDj=txbmvoQgKtcJxrmzX3DR7xB05c0RQ@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <gerlitz.or@gmail.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog033.obsmtp.com ([74.125.150.107]:43083 "HELO
	na6sys009bog033.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751028AbaI2UTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:19:50 -0400
Received: by mail-we0-f178.google.com with SMTP id t60so13835015wes.9
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 13:19:48 -0700 (PDT)
In-Reply-To: <1411962607-27878-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2014 at 8:50 PM, Tom Herbert <therbert@google.com> wrote:
> Add ndo_gso_check which a device can define to indicate whether is
> is capable of doing GSO on a packet. This funciton would be called from
> the stack to determine whether software GSO is needed to be done. A
> driver should populate this function if it advertises GSO types for
> which there are combinations that it wouldn't be able to handle. For
> instance a device that performs UDP tunneling might only implement
> support for transparent Ethernet bridging type of inner packets
> or might have limitations on lengths of inner headers.
>
> Signed-off-by: Tom Herbert <therbert@google.com>

Offloads that might have limitations extend beyond GSO - checksum is
another possibility that could need something like a length check.

In addition, while I would also like to be optimistic about the
capabilities of existing NICs it's unlikely that any of them that are
advertising SKB_GSO_UDP_TUNNEL can actually do it with full
generality. So unless we can get the driver writers to chime in about
their capabilities (maybe we can, there's only a handful of them right
now), we probably need to provide a more conservative implementation
for those drivers. I guess I would probably do length equal to VXLAN
and perhaps containing Ethernet as a balance between the most
conservative and the most optimistic.
