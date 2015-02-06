From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 25/29] net: vrf: Handle VRF any context
Date: Thu, 05 Feb 2015 18:23:18 -0700
Message-ID: <54D41786.6060507@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-26-git-send-email-dsahern@gmail.com> <54D3742E.9020607@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:63429 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbbBFBXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 20:23:20 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so3793808igd.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 17:23:19 -0800 (PST)
In-Reply-To: <54D3742E.9020607@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 6:46 AM, Nicolas Dichtel wrote:
> Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
>> VRF any context applies only to tasks to and sockets. Devices are
>> associated with a single VRF, and skb's by extension are connected t=
o
>> a single VRF.
>>
>> Listen sockets and unconnected sockets can be opened in a "VRF any"
>> context allowing a single daemon to provide service across all VRFs
>> in a namespace. Connected sockets must be in a specific vrf context.
>> Accepted sockets acquire the VRF context from the device the packet
>> enters (via the skb).
>>
>> "VRF any" context is also useful for tasks wanting to view L3/L4
>> data for all VRFs.
>>
>> Signed-off-by: David Ahern <dsahern@gmail.com>
>> ---
> [snip]
>> +static inline int neigh_parms_net_ctx_eq_any(const struct neigh_par=
ms
>> *parms,
>> +                         const struct net_ctx *net_ctx)
>> +{
>> +#ifdef CONFIG_NET_NS
>> +    if (net_eq(neigh_parms_net(parms), net_ctx->net) &&
>> +        (vrf_eq(neigh_parms_vrf(parms), net_ctx->vrf) ||
>> +         vrf_is_any(net_ctx->vrf))) {
>> +        return 1;
>> +    }
>> +
>> +    return 0;
>> +#else
>> +    return 1;
>> +#endif
> If I understand well, the way the patch is done, VRF can be used only=
 if
> CONFIG_NET_NS is enabled.
> But if I'm not wrong, it could be independent. Am I right?
>

Yes. VRF can exist without namespace. It became tedious to keep trackin=
g=20
the CONFIG_NET_NS for the RFC set. Would certainly do that for later=20
versions.
