From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 1/3] openvswitch: Reject ct_state masks for unknown bits
Date: Thu, 15 Oct 2015 11:09:47 -0700
Message-ID: <CALnjE+pa4O5F82xELSHmnymcLLm-Vz+FvcLwCui3Kd+abE=sTg@mail.gmail.com>
References: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35360 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbbJOSJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 14:09:48 -0400
Received: by igbkq10 with SMTP id kq10so724647igb.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 11:09:48 -0700 (PDT)
In-Reply-To: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:10 AM, Joe Stringer <joestringer@nicira.com> wrote:
> Currently, 0-bits are generated in ct_state where the bit position is
> undefined, and matches are accepted on these bit-positions. If userspace
> requests to match the 0-value for this bit then it may expect only a
> subset of traffic to match this value, whereas currently all packets
> will have this bit set to 0. Fix this by rejecting such masks.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
>  net/openvswitch/conntrack.h    | 11 +++++------
>  net/openvswitch/flow_netlink.c |  5 ++++-
>  2 files changed, 9 insertions(+), 7 deletions(-)
>
> diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
> index da8714942c95..2d42b3640117 100644
> --- a/net/openvswitch/conntrack.h
> +++ b/net/openvswitch/conntrack.h
> @@ -35,12 +35,9 @@ void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key);
>  int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb);
>  void ovs_ct_free_action(const struct nlattr *a);
>
> -static inline bool ovs_ct_state_supported(u32 state)
> -{
> -       return !(state & ~(OVS_CS_F_NEW | OVS_CS_F_ESTABLISHED |
> -                        OVS_CS_F_RELATED | OVS_CS_F_REPLY_DIR |
> -                        OVS_CS_F_INVALID | OVS_CS_F_TRACKED));
> -}
Can you also remove definition of ovs_ct_state_supported() in case
where conntrack is not enabled.

Otherwise looks good.

Acked-by: Pravin B Shelar <pshelar@nicira.com>
