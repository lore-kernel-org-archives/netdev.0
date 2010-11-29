From: David Shwatrz <dshwatrz@gmail.com>
Subject: Re: [net-next-2.6] XFRM: remove unused member in xfrm_encap_tmpl.
Date: Mon, 29 Nov 2010 21:15:12 +0200
Message-ID: <AANLkTinQ1qbp9SyWgw7TdvH=5x_1AA6zqLkaa7c4PBGQ@mail.gmail.com>
References: <AANLkTiknTcWaRykGOTbw6JpFZN-ePnRXd3iWz86yYHKi@mail.gmail.com>
	<4CF3EBF2.5060308@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40476 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359Ab0K2TPP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 14:15:15 -0500
Received: by wyb28 with SMTP id 28so4766242wyb.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 11:15:14 -0800 (PST)
In-Reply-To: <4CF3EBF2.5060308@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Thanks, Timo.

But isn't something wrong here ?

According to RFC 3948:
=2E..
3.1.2.  Transport Mode Decapsulation NAT Procedure

When a transport mode has been used to transmit packets, contained
   TCP or UDP headers will have incorrect checksums due to the change o=
f
   parts of the IP header during transit.  This procedure defines how t=
o
   fix these checksums
=2E..
incrementally recompute the
       TCP/UDP checksum:

       *  Subtract the IP source address in the received packet from th=
e
          checksum.
       *  Add the real IP source address received via IKE to the
          checksum (obtained from the NAT-OA)
=2E..

So where do we pass the NAT-OA, received from IKE messages,  to this
checksum recalculation process, which should be done in the kernel
(layer 4 TCP/UDP I suppose) ?

Should'nt this process be done in the kernel ?

Isn't there something missing here ?

Rgs,
DS

2010/11/29 Timo Ter=E4s <timo.teras@iki.fi>:
> On 01/-10/-28163 09:59 PM, David Shwatrz wrote:
>> Hi,
>> =A0The patch removes unused member in xfrm_encap_tmpl.
>>
>> Regards,
>> David Shwartz
>>
>>
>> Signed-off-by: David Shwartz <dshwatrz@gmail.com>
>>
>>
>> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
>> index b971e38..7312707 100644
>> --- a/include/linux/xfrm.h
>> +++ b/include/linux/xfrm.h
>> @@ -235,7 +235,6 @@ struct xfrm_encap_tmpl {
>> =A0 =A0 =A0 __u16 =A0 =A0 =A0 =A0 =A0 encap_type;
>> =A0 =A0 =A0 __be16 =A0 =A0 =A0 =A0 =A0encap_sport;
>> =A0 =A0 =A0 __be16 =A0 =A0 =A0 =A0 =A0encap_dport;
>> - =A0 =A0 xfrm_address_t =A0encap_oa;
>> =A0};
>>
>> =A0/* AEVENT flags =A0*/
>
> struct xfrm_encap_tmpl is exposed to userland via netlink. This would
> break ABI.
>
