From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/5] vxlan: Group Policy extension
Date: Wed, 14 Jan 2015 16:18:14 -0800
Message-ID: <CA+mtBx-CH2=D-wKmkjVTvhQOWhbf73NxcGrXrXOPE-E2PzJajQ@mail.gmail.com>
References: <cover.1421280226.git.tgraf@suug.ch>
	<c73939bbb55a8e450de7931d830e0467a8340665.1421280226.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.ne>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:50756 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbbAOASO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 19:18:14 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so12045755iec.8
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 16:18:14 -0800 (PST)
In-Reply-To: <c73939bbb55a8e450de7931d830e0467a8340665.1421280226.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 99df0d7..06f7196 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -126,6 +126,7 @@ struct vxlan_dev {
>         __u8              tos;          /* TOS override */
>         __u8              ttl;
>         u32               flags;        /* VXLAN_F_* in vxlan.h */
> +       u32               exts;         /* Enabled extensions */
>

Thomas, why not just make a VXAM_F_GPB flag? Then this setting can be
saved in the flags for vxlan_dev and vxlan_sock so no exts field.

Tom


>         struct work_struct sock_work;
>         struct work_struct igmp_join;
> @@ -620,7 +621,8 @@ static struct sk_buff **vxlan_gro_receive(struct sk_buff **head,
>                         continue;
>
