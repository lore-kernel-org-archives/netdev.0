From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net-next:master 126/134] include/net/ipv6.h:555:26: sparse: cast to
 restricted __be32
Date: Mon, 14 Jan 2013 10:55:59 +0800
Message-ID: <20130114025559.GA9331@localhost>
References: <50f370b4.sImtI783JLS2vUID%yuanhan.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7034 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755557Ab3ANC4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jan 2013 21:56:04 -0500
Content-Disposition: inline
In-Reply-To: <50f370b4.sImtI783JLS2vUID%yuanhan.liu@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi YOSHIFUJI,

=46YI, there are new sparse warnings show up in

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.gi=
t master
head:   25d46f43a911b08c5aa8c8fd4fe7fa9b36445068
commit: 3e4e4c1f2da66b29ee9379ca29f8dd620c2b5a1f [126/134] ipv6: Introd=
uce ip6_flow_hdr() to fill version, tclass and flowlabel.

>> include/net/ipv6.h:555:26: sparse: cast to restricted __be32
>> include/net/ipv6.h:555:63: sparse: restricted __be32 degrades to int=
eger
>> include/net/ipv6.h:555:24: sparse: incorrect type in assignment (dif=
ferent base types)
   include/net/ipv6.h:555:24:    expected restricted __be32 [usertype] =
<noident>
   include/net/ipv6.h:555:24:    got unsigned int

vim +555 include/net/ipv6.h

971f359d YOSHIFUJI Hideaki            2005-11-08  549  /*
3e4e4c1f YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E 2013-=
01-13  550   *	Header manipulation
3e4e4c1f YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E 2013-=
01-13  551   */
3e4e4c1f YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E 2013-=
01-13  552  static inline void ip6_flow_hdr(struct ipv6hdr *hdr, unsign=
ed int tclass,
3e4e4c1f YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E 2013-=
01-13  553  				__be32 flowlabel)
3e4e4c1f YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E 2013-=
01-13  554  {
3e4e4c1f YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E 2013-=
01-13 @555  	*(__be32 *)hdr =3D ntohl(0x60000000 | (tclass << 20)) | fl=
owlabel;
3e4e4c1f YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E 2013-=
01-13  556  }
3e4e4c1f YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E 2013-=
01-13  557 =20
3e4e4c1f YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E 2013-=
01-13  558  /*

---
0-DAY kernel build testing backend         Open Source Technology Cente=
r
=46engguang Wu, Yuanhan Liu                              Intel Corporat=
ion
