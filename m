From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/6] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Wed, 1 Feb 2012 16:19:55 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1202011616280.26332@frira.zrqbmnf.qr>
References: <1327269381-20748-1-git-send-email-richard@nod.at> <1327269381-20748-2-git-send-email-richard@nod.at> <CAFLxGvzLvdyyaBvh7LCM2+tTmKobK6n8jTRoH8NXd=MVmN4ocA@mail.gmail.com> <alpine.LNX.2.01.1201310208370.7433@frira.zrqbmnf.qr>
 <CAFLxGvwh5J=CR6OzST7ok6cEuHPWTziDN5TSbGxAiJOpANpAAQ@mail.gmail.com> <alpine.LNX.2.01.1202011523590.18699@frira.zrqbmnf.qr> <CAFLxGvzgvvfkKQ7r2WWD6jOr+nLCTOE0MvXaMxfCR3HPAHivxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	eric.dumazet@gmail.com, Pablo Neira Ayuso <pablo@netfilter.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAFLxGvzgvvfkKQ7r2WWD6jOr+nLCTOE0MvXaMxfCR3HPAHivxg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2012-02-01 16:08, richard -rw- weinberger wrote:
>> I don't see that extra pointer (outside xt_log_info_v1) that you tal=
k about.
>> +struct xt_log_info_v1 {
>> + =C2=A0 =C2=A0 =C2=A0 unsigned char level;
>> + =C2=A0 =C2=A0 =C2=A0 unsigned char logflags;
>> + =C2=A0 =C2=A0 =C2=A0 char prefix[30];
>> +
>> + =C2=A0 =C2=A0 =C2=A0 char ring_name[30];
>> + =C2=A0 =C2=A0 =C2=A0 unsigned long ring_size;
>> + =C2=A0 =C2=A0 =C2=A0 struct xt_LOG_ring_ctx *rctx;
>> +};
>
>See:
>include/linux/netfilter/xt_LOG.h (user space part).
>
>+struct xt_log_info_v1 {
>+       unsigned char level;
>+       unsigned char logflags;
>+       char prefix[30];
>+
>+       char ring_name[30];
>+       unsigned long ring_siVs.ze;
>+};
>
>Here is no context pointer.

Aw don't do that. That is not maintainer-friendly (since headers
are more or less regularly updated by copying from kernel sources).
Keep the structs the same on each side.

That's why we have .userspacesize in the first place.
See libxt_quota.c on how it's done.

	.size =3D XT_ALIGN(sizeof(struct xt_log_info_v1)),
	.userspacesize =3D offsetof(struct xt_log_info_v1, firstkernelmember),
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
