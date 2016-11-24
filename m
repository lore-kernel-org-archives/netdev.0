From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 0/2] tc/cls_flower: Support for ip tunnel
 metadata set/release/classify
Date: Thu, 24 Nov 2016 16:33:55 +0100
Message-ID: <20161124163355.1c4d686f@griffin>
References: <20161121102056.13468-1-amir@vadai.me>
        <20161124143856.43fa54d6@griffin>
        <20161124150633.GA27727@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50006 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966349AbcKXPd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 10:33:59 -0500
In-Reply-To: <20161124150633.GA27727@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Nov 2016 17:06:33 +0200, Amir Vadai wrote:
> So you mean to just unconditionally call skb_dst_drop() from
> act_mirred()?

That's one option. Or just leave the dst there, it shouldn't matter?
(Except for forwarding to a different tunnel but as I said, it's a
corner case and we may have a "tunnel_key unset" action for that.)

> The use case we already have that uses the release action is the
> hardware offload support, which is already in the kernel.
> It is using the "tunnel_key release" action to signal the hardware to
> strip off the ip tunnel headers.

The tunnel headers must be removed upon reception on the tunnel
interface without specifying anything, because that's how the Linux
kernel behaves currently. If this is offloaded, this behavior must be
preserved. I don't see how "tunnel_key release" might be used for
stripping the headers.

 Jiri
