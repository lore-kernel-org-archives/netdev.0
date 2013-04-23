From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] net: Loosen constraints for recalculating
 checksum in skb_segment()
Date: Tue, 23 Apr 2013 16:43:58 -0700
Message-ID: <CAEP_g=_nTah2xN2KHxBPtYQyFUWH+8frybGt1Zv=0Q9ButZH5w@mail.gmail.com>
References: <1366683556-4956-1-git-send-email-horms@verge.net.au> <1366683556-4956-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:58160 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755970Ab3DWXoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 19:44:19 -0400
Received: by mail-ob0-f198.google.com with SMTP id tb18so6600420obb.1
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 16:44:19 -0700 (PDT)
In-Reply-To: <1366683556-4956-3-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 7:19 PM, Simon Horman <horms@verge.net.au> wrote:
> In the case where a non-MPLS GSO skb becomes an MPLS GSO skb, via
> Open vSwitch's push MPLS action it is desirable to provide segmentation
> in software. In this case the original protocol of the skb may have allowed
> its checksumming to be offloaded but this may no longer be supported now
> the skb is MPLS. Actually it seems to me that this is the likely case.
>
> In order to allow the checksum to be updated in this case loosen
> the rules for recalculating the checksum on in skb_segment().
>
> N.B.: I must confess that I am a little unsure of the details of
> the implementation of skb_checksum(). But I have observed that this
> is necessary as skb_checksum() hits the following:
>
>                 if (!hsize && i >= nfrags) {
>                         ...
>                         fskb = fskb->next;
>                         ...
>                 }
>                 ...
>                 if (fskb != skb_shinfo(skb)->frag_list)
>                         ...
>
> Signed-off-by: Simon Horman <horms@verge.net.au>

I'm surprised at the need for changes here since neither vlans nor
tunneling protocols needed something similar. Do you know what is
special about MPLS that is triggering this?
