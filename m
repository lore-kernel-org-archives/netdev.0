From: Fan Du <fan.du@windriver.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Tue, 16 Jul 2013 17:58:52 +0800
Message-ID: <51E5195C.90703@windriver.com>
References: <51D6D3A0.7050106@gmail.com>	<51DC282C.9090007@gmail.com>	<51DF74BE.6000001@windriver.com> <20130712.155808.2237731776440357524.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<nicolas.dichtel@6wind.com>, <netdev@vger.kernel.org>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51053 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753845Ab3GPJ7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 05:59:15 -0400
In-Reply-To: <20130712.155808.2237731776440357524.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B407=E6=9C=8813=E6=97=A5 06:58, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Fri, 12 Jul 2013 11:15:10 +0800
>
>> But problem still arise when we attempt to delete address
>> in multi-home mode, deleting an IPv6 address does not invalidate
>> any dst which source address is the same at the deleted one.
>> Which means sctp cannot rely on ip6_dst_check in this scenario.
>
> I still cannot understand why this is an SCTP specific issue.

It's not SCTP specific, it's shared by all all layer 4 protocol IMHO.
The issue of SCTP IPv6 doesn't check IPv6 dst validness has been addres=
sed
using *only* dst_cookie as other layer 4 protocol does for its sock.
But this scheme cannot cover scenario when delete primary address to su=
pport
SCTP multi-home feature, this is where the concern is.

Use netsend to send a large file using DCCP, considering the sender
host has two IPv6 address, while sending, delete the one netsend curren=
tly
using. Wireshark could catch the sender is still transmit packet out us=
ing
the deleted address in a slowly manner.

All of those boils down to one question that I cannot resist to ask:
If delete an IPv6 address(*1*), whether the original rt/dst destinate f=
or a
remote address(*2*) using the deleted address as source address is stil=
l legal
for subsequent usage in current kernel IPv6 routing implementation???

btw, (*1*) and (*2*) are on quite different node in the binary tree as =
well
as different leaf.

> Specifically, I cannot see why address addition/deletion doesn't
> cause problems for cached ipv6 routes in UDP and TCP sockets too.
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
