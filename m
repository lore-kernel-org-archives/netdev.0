From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/2] openvswitch: fix the calculation of checksum for vlan header
Date: Fri, 22 Feb 2013 17:04:20 -0800
Message-ID: <CAEP_g=-hHQRSg95rJEgMkFkvzgXfEPvmgU38-Es4SpEHmXGd7w@mail.gmail.com>
References: <1361525547-21808-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:48601 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755239Ab3BWBEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 20:04:42 -0500
Received: by mail-ob0-f200.google.com with SMTP id un3so5983220obb.3
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 17:04:42 -0800 (PST)
In-Reply-To: <1361525547-21808-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 22, 2013 at 1:32 AM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> In vlan_insert_tag(), we insert a 4-byte VLAN header _after_
> mac header:
>
>         memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
>         ...
>         veth->h_vlan_proto = htons(ETH_P_8021Q);
>         ...
>         veth->h_vlan_TCI = htons(vlan_tci);
>
> so after it, we should recompute the checksum to include these 4 bytes.
> skb->data still points to the mac header, therefore VLAN header is at
> (2 * ETH_ALEN = 12) bytes after it, not (ETH_HLEN = 14) bytes.
>
> This can also be observed via tcpdump:
>
>          0x0000:  ffff ffff ffff 5254 005d 6f6e 8100 000a
>          0x0010:  0806 0001 0800 0604 0001 5254 005d 6f6e
>          0x0020:  c0a8 026e 0000 0000 0000 c0a8 0282
>
> Similar for __pop_vlan_tci(), the vlan header we remove is the one
> overwritten in:
>
>         memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
>
> Therefore the VLAN_HLEN = 4 bytes after 2 * ETH_ALEN is the part
> we want to sub from checksum.
>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
