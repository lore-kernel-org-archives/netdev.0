From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] loopback: explicitly set pkt_type to PACKET_HOST
Date: Wed, 14 May 2014 14:24:33 -0700
Message-ID: <CAM_iQpWSek9=F=WYAzBgE41_C+ep_=V4yOidBm9EYgKDXYB-SA@mail.gmail.com>
References: <1400092762-23287-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:42093 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbaENVYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 17:24:34 -0400
Received: by mail-oa0-f41.google.com with SMTP id m1so198673oag.0
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 14:24:34 -0700 (PDT)
In-Reply-To: <1400092762-23287-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 11:39 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> From: Cong Wang <cwang@twopensource.com>
>
> In a corner case where I redirect the packets from veth to lo,
> packets are dropped silently when entering IP stack. This is
> due to we have a different MAC addr on veth, so the packets are
> marked as PACKET_OTHERHOST. And after they are redirect to lo,
> this value is kept since lo has the same MAC addr with the packets.
> Loopback should explicitly set it to PACKET_HOST before calling
> eth_type_trans() for this specific case.
>

Note, I am not quite sure about this. There might be some other case
we xmit a packet with !PACKET_HOST via loopback?

PACKET_BROADCAST, PACKET_MULTICAST and PACKET_OTHERHOST
could be fixed up by eth_type_trans().

PACKET_USER and PACKET_KERNEL are only used by netlink.

PACKET_FASTROUTE is unused.

PACKET_OUTGOING seems only used by packet socket and decnet.

PACKET_LOOPBACK is used by multicast but should completely skip loopback
device via dev_loopback_xmit().
