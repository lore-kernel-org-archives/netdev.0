From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/2] vlan: adjust vlan_set_encap_proto() for its callers
Date: Fri, 22 Feb 2013 17:05:01 -0800
Message-ID: <CAEP_g=_eWXuR_3zUYsbBiAjaCJQjRpSmUypqpJe5_jwN=rmM0Q@mail.gmail.com>
References: <1361525547-21808-1-git-send-email-amwang@redhat.com> <1361525547-21808-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:47368 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754922Ab3BWBFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 20:05:22 -0500
Received: by mail-oa0-f72.google.com with SMTP id j6so6232534oag.11
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 17:05:21 -0800 (PST)
In-Reply-To: <1361525547-21808-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 22, 2013 at 1:32 AM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> There are two places to call vlan_set_encap_proto():
> vlan_untag() and __pop_vlan_tci().
>
> vlan_untag() assumes skb->data points after mac addr, otherwise
> the following code
>
>         vhdr = (struct vlan_hdr *) skb->data;
>         vlan_tci = ntohs(vhdr->h_vlan_TCI);
>         __vlan_hwaccel_put_tag(skb, vlan_tci);
>
>         skb_pull_rcsum(skb, VLAN_HLEN);
>
> won't be correct. But __pop_vlan_tci() assumes points _before_
> mac addr.
>
> In vlan_set_encap_proto(), it looks for some magic L2 value
> after mac addr:
>
>         rawp = skb->data;
>         if (*(unsigned short *) rawp == 0xFFFF)
>         ...
>
> Therefore __pop_vlan_tci() is obviously wrong.
>
> A quick fix is avoiding using skb->data in vlan_set_encap_proto(),
> use 'vhdr+1' is always correct in both cases.
>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Acked-by: Jesse Gross <jesse@nicira.com>
