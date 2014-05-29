From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 7/7] vxlan: Add support for UDP checksums (v4 TX, v6 zero csums)
Date: Thu, 29 May 2014 16:38:48 -0700
Message-ID: <CA+mtBx84sivSJ8P_rFoA=ijT1U1_sd61C+V-JJwMdYyQhbVHig@mail.gmail.com>
References: <alpine.DEB.2.02.1405282114100.7294@tomh.mtv.corp.google.com>
	<CAEP_g=9tvWCZ32HKsN0bpn-qxTcgPS8PupSRi5S0h665VDpEoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:65094 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395AbaE2Xis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 19:38:48 -0400
Received: by mail-ig0-f172.google.com with SMTP id uy17so164126igb.5
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 16:38:48 -0700 (PDT)
In-Reply-To: <CAEP_g=9tvWCZ32HKsN0bpn-qxTcgPS8PupSRi5S0h665VDpEoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 3:45 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Wed, May 28, 2014 at 9:24 PM, Tom Herbert <therbert@google.com> wrote:
>> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
>> index a93efa3..0edbd95 100644
>> --- a/net/openvswitch/vport-vxlan.c
>> +++ b/net/openvswitch/vport-vxlan.c
>> @@ -122,7 +122,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
>>         vxlan_port = vxlan_vport(vport);
>>         strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
>>
>> -       vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, false);
>> +       vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, 0);
>
> OVS actually already has support for specifying that checksums should
> be calculated/verified plumbed down to the kernel. This is used
> already with GRE (via the TUNNEL_CSUM flag). If we modeled VXLAN
> similarly then it might make the two protocols more similar and give
> us OVS support for free.

I tend to agree, it would be nice if vxlan would be configured like
GRE, use tnl_ptk_info, etc. But, it looks like vxlan is pretty
divergent, so I'd like to decouple doing that from this patch set.

For setting use of csums in vxlan-ovs it should be a matter of adding
IFLA_VXLAN_UDP_CSUM (IFLA_VXLAN_UDP_ZERO_CSUM6_TX for IPv6) flags
argument to vxlan_sock_add. Do you see any issues with that?

Thanks,
Tom
