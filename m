From: =?utf-8?B?6auY5bOw?= <fgao@ikuai8.com>
Subject: =?utf-8?Q?=E7=AD=94=E5=A4=8D:_=5BPATCH_1/1=5D_netfilter:_Add_h?=
	=?utf-8?Q?elper_array_register/unregister_?=
	=?utf-8?Q?functions?=
Date: Wed, 20 Jul 2016 09:02:52 +0800
Message-ID: <015201d1e222$71cfe330$556fa990$@ikuai8.com>
References: <1468813163-18139-1-git-send-email-fgao@ikuai8.com> <CAML_gOeTMwf2fDTwwJ9MbjPvnSSx8PDxBy55xE+7EMo5yy5UcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Pablo Neira Ayuso'" <pablo@netfilter.org>,
	"'Patrick McHardy'" <kaber@trash.net>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <gfree.wind@gmail.com>
To: "'Liping Zhang'" <zlpnobody@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG252.QQ.COM ([183.60.52.105]:46307 "EHLO smtpbg252.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbcGTBDc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 21:03:32 -0400
In-Reply-To: <CAML_gOeTMwf2fDTwwJ9MbjPvnSSx8PDxBy55xE+7EMo5yy5UcA@mail.gmail.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh, thanks Liping.
I have not found the extra port styles are different of irc, sane and t=
ftp with ftp.

Hi Pablo,
Then should I modify the original patch or send a new one?


-----=E9=82=AE=E4=BB=B6=E5=8E=9F=E4=BB=B6-----
=E5=8F=91=E4=BB=B6=E4=BA=BA: Liping Zhang [mailto:zlpnobody@gmail.com]=20
=E5=8F=91=E9=80=81=E6=97=B6=E9=97=B4: 2016=E5=B9=B47=E6=9C=8820=E6=97=A5=
 8:51
=E6=94=B6=E4=BB=B6=E4=BA=BA: fgao@ikuai8.com
=E6=8A=84=E9=80=81: Pablo Neira Ayuso <pablo@netfilter.org>; Patrick Mc=
Hardy <kaber@trash.net>; netfilter-devel@vger.kernel.org; netdev@vger.k=
ernel.org; linux-kernel@vger.kernel.org; gfree.wind@gmail.com
=E4=B8=BB=E9=A2=98: Re: [PATCH 1/1] netfilter: Add helper array registe=
r/unregister functions

2016-07-18 11:39 GMT+08:00  <fgao@ikuai8.com>:
> From: Gao Feng <fgao@ikuai8.com>
>
> Add nf_ct_helper_init, nf_conntrack_helpers_register/unregister
> functions to enhance the conntrack helper codes.

I think this patch is breaking something ...

This irc:
> -               if (ports[i] =3D=3D IRC_PORT)
> -                       sprintf(irc[i].name, "irc");
> -               else
> -                       sprintf(irc[i].name, "irc-%u", i);
> -
> -               ret =3D nf_conntrack_helper_register(&irc[i]);
> +               nf_ct_helper_init(&irc[i], AF_INET, IPPROTO_TCP, "irc=
",
> +                                 IRC_PORT, ports[i], &irc_exp_policy=
, 0, 0,
> +                                 help, NULL, THIS_MODULE);
> +       }

This sip:
> -                       if (ports[i] =3D=3D SIP_PORT)
> -                               sprintf(sip[i][j].name, "sip");
> -                       else
> -                               sprintf(sip[i][j].name, "sip-%u", i);

And this tftp:
> -                       if (ports[i] =3D=3D TFTP_PORT)
> -                               sprintf(tftp[i][j].name, "tftp");
> -                       else
> -                               sprintf(tftp[i][j].name, "tftp-%u", i=
);

=46or example, if the user install the nf_conntrack_tftp module an spec=
ify the ports to "69,10069", then the helper name is "tftp" and "tftp-1=
".

But apply this patch, the helper name will be changed to "tftp" and "tf=
tp-10069", this may break the existing iptables rules which used the he=
lper match or CT target.

And this was already discussed  at https://patchwork.ozlabs.org/patch/6=
22238/
