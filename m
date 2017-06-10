From: Thomas Winter <Thomas.Winter@alliedtelesis.co.nz>
Subject: Re: [PATCH net v3] net: ipmr: Fix some mroute forwarding issues in
 vrf's
Date: Sat, 10 Jun 2017 23:39:42 +0000
Message-ID: <1497137970727.29475@alliedtelesis.co.nz>
References: <20170610203017.4085-1-sharpd@cumulusnetworks.com>
 <20170610.190759.166589591911771854.davem@davemloft.net>,<a7d1c403-408c-d8ec-d552-ee417be68b50@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
        "yotamg@mellanox.com" <yotamg@mellanox.com>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
To: David Ahern <dsahern@gmail.com>,
        David Miller <davem@davemloft.net>,
        "sharpd@cumulusnetworks.com" <sharpd@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:58837 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdFJXjs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 19:39:48 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 8C6CF8448B
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 11:39:45 +1200 (NZST)
In-Reply-To: <a7d1c403-408c-d8ec-d552-ee417be68b50@gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't think we've seen this issue but patch looks good.=0A=
________________________________________=0A=
From: David Ahern <dsahern@gmail.com>=0A=
Sent: 11 June 2017 11:33=0A=
To: David Miller; sharpd@cumulusnetworks.com=0A=
Cc: netdev@vger.kernel.org; Thomas Winter; nikolay@cumulusnetworks.com; yot=
amg@mellanox.com; idosch@mellanox.com; roopa@cumulusnetworks.com=0A=
Subject: Re: [PATCH net v3] net: ipmr: Fix some mroute forwarding issues in=
 vrf's=0A=
=0A=
On 6/10/17 5:07 PM, David Miller wrote:=0A=
> From: Donald Sharp <sharpd@cumulusnetworks.com>=0A=
> Date: Sat, 10 Jun 2017 16:30:17 -0400=0A=
>=0A=
>> This patch fixes two issues:=0A=
>>=0A=
>> 1) When forwarding on *,G mroutes that are in a vrf, the=0A=
>> kernel was dropping information about the actual incoming=0A=
>> interface when calling ip_mr_forward from ip_mr_input.=0A=
>> This caused ip_mr_forward to send the multicast packet=0A=
>> back out the incoming interface.  Fix this by=0A=
>> modifying ip_mr_forward to be handed the correctly=0A=
>> resolved dev.=0A=
>>=0A=
>> 2) When a unresolved cache entry is created we store=0A=
>> the incoming skb on the unresolved cache entry and=0A=
>> upon mroute resolution from the user space daemon,=0A=
>> we attempt to forward the packet.  Again we were=0A=
>> not resolving to the correct incoming device for=0A=
>> a vrf scenario, before calling ip_mr_forward.=0A=
>> Fix this by resolving to the correct interface=0A=
>> and calling ip_mr_forward with the result.=0A=
>>=0A=
>> Fixes: e58e41596811 ("net: Enable support for VRF with ipv4 multicast")=
=0A=
>> Signed-off-by: Donald Sharp <sharpd@cumulusnetworks.com>=0A=
>=0A=
> David, please review.=0A=
>=0A=
=0A=
Responded. Would be good for the Mellanox team (and Thomas) to chime in=0A=
as well.=0A=
