From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 net-next 0/7] net: foo-over-udp (fou)
Date: Mon, 15 Sep 2014 21:08:13 +0300
Message-ID: <CAJ3xEMjC5PQENzCXS9SNVm6zUVn7pydxf1MLQ57Br1sGjD1ngQ@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:47000 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231AbaIOSIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 14:08:14 -0400
Received: by mail-oa0-f48.google.com with SMTP id g18so2816929oah.21
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 11:08:13 -0700 (PDT)
In-Reply-To: <1410750483-3236-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 6:07 AM, Tom Herbert <therbert@google.com> wrote:
[...]
> * Notes
>   - This patch set does not implement GSO for FOU. The UDP encapsulation
>     code assumes TEB, so that will need to be reimplemented.

Can you please clarify this point little further? Specifically, today
few NICs are
advertizing NETIF_F_GSO_UDP_TUNNEL when they are practically GSO
capable only w.r.t to VXLAN. What happens when such NIC expose this
cap and a large guest frame goes through GRE over UDP or alike tunneling?

>   - I really don't expect/want devices to have special support for any
>     of this. Generic checksum offload mechanisms (NETIF_HW_CSUM
>     and use of CHECKSUM_COMPLETE) should be sufficient. RSS and flow
>     steering is provided by commonly implemented UDP hashing. GRO/GSO
>     seem fairly comparable with LRO/TSO already.

Again, today NICs are advertizing checksum offloads capability in
enc_hw_features but aren't capable to compute (say) the TCP checksum
of the inner
packet regardless of which actual tunneling is used (e.g VXLAN vs
GRE), a bit inconsistent?
