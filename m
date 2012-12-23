From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 over Firewire
Date: Sun, 23 Dec 2012 17:23:11 +0900
Message-ID: <50D6BF6F.2030207@linux-ipv6.org>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com> <50D4BD2F.7060006@linux-ipv6.org> <50D54ED9.6090908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:35543 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750741Ab2LWIXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 03:23:14 -0500
In-Reply-To: <50D54ED9.6090908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012=E5=B9=B412=E6=9C=8822=E6=97=A5 15:10), Stephan Gatzka wrote:
>=20
>> Something like this:
>>
>>   static inline int ndisc_opt_addr_space(struct net_device *dev)
>>   {
>> -       return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad=
(dev->type));
>> +       switch (dev->type) {
>> +       case ARPHRD_IEEE1394:
>> +               return sizeof(struct ndisc_opt_ieee1394_llinfo);
>> +       default:
>> +               return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_op=
tion_pad(dev->type));
>> +       }
>>   }
>>
>> --yoshfuji
>>
>=20
> O.k., this has the advantage that only ndisc packets get some more me=
mory, but the question is if we are under such a hard memory pressure t=
hat we don't allow that.
>=20
> Your solution has the disadvantage that now I have to publish struct =
ndisc_opt_ieee1394_llinfo to the ndisc stuff. Nobody in ndisc.c really =
wants to deal with that structure, only the size is of interest. So kee=
ping this struct private is less invasive to the rest of linux. Just my=
 two cents.

net/ipv6/ndisc.c SHOULD build full NDP messages for IPv6
over IEEE1394 as we do it for Infiniband.

Please, please do not try to mangle them in the driver.

--yoshfuji
