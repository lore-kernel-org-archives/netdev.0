From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] IPv6: Fix the data length of get destination options
 with short length
Date: Thu, 29 May 2008 10:29:47 +0800
Message-ID: <483E151B.2000804@cn.fujitsu.com>
References: <483D0070.2090909@cn.fujitsu.com> <20080528.201322.26342915.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@sunset.davemloft.net,
	FNST-Wei Yongjun <yjwei@cn.fujitsu.com>,
	netdev@vger.kernel.org, Wang Chen <wangchen@cn.fujitsu.com>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55205 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbYE2CbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 22:31:09 -0400
In-Reply-To: <20080528.201322.26342915.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:

> POSIX says that the object pointed to by the option_len argument shal=
l be
> modified to indicate the actual length of the value.
> Do you think this change conforms to the spec?
>=20

We use the codes below to get the destination options,the length cnt is=
 half of the option length.
	cnt =3D sizeof(incmsg) / 2;
	if (getsockopt(sk, IPPROTO_IPV6, IPV6_DSTOPTS,
		       (char *)incmsg, &cnt) =3D=3D -1)=20

We can see from net/ipv6/ipv6_sockglue.c,the code below store half of t=
he option length to incmsg,
so the acture data length of incmsg is half of the option length.Accord=
ing to RFC(as you said=20
"option_len argument shall be modified to indicate the actual length of=
 the value") the cnt=20
should specify the data length of incmsg,that is half of the option len=
gth.So we should return len=20
instead of ipv6_optlen(hdr).
 832         len =3D min_t(unsigned int, len, ipv6_optlen(hdr));
 833         if (copy_to_user(optval, hdr, len))
 834                 return -EFAULT;


--=20
Regards
Yang Hongyang
=20
A new email address of FJWAN is launched from Apr.1 2007.
The updated address is: yanghy@cn.fujitsu.com
--------------------------------------------------
Yang Hongyang
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630566-812
=46UJITSU INTERNAL: 79955-812
=46AX: +86+25-83317685
EMAIL: yanghy@cn.fujitsu.com
--------------------------------------------------
This communication is for use by the intended recipient(s) only and may=
 contain information that is privileged, confidential and exempt from d=
isclosure under applicable law. If you are not an intended recipient of=
 this communication, you are hereby notified that any dissemination, di=
stribution or copying hereof is strictly prohibited.  If you have recei=
ved this communication in error, please notify me by reply e-mail, perm=
anently delete this communication from your system, and destroy any har=
d copies you may have printed

