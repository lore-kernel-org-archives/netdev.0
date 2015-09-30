From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next 1/2] openvswitch: add tunnel protocol
 to sw_flow_key
Date: Wed, 30 Sep 2015 13:25:12 -0700
Message-ID: <CAEP_g=--y7J36S7fKVUA2Hjb=Sy=iRHot2XsJ=RbNTM20HhA1A@mail.gmail.com>
References: <cover.1443548447.git.jbenc@redhat.com> <428cee4cb7e04cfea5bef90b37d257562ea78a83.1443548447.git.jbenc@redhat.com>
 <CALnjE+qWmENWj_hL87++Sk=zzrvj2U0VAEW26ySAjg5RsDymuA@mail.gmail.com>
 <20150930090946.4e4bb610@griffin> <CALnjE+pNXwAisxyZnb3Lik1ZMa_0QLvLip9TOOqLEZUbboT8BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:34273 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932506AbbI3UZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 16:25:33 -0400
Received: by labzv5 with SMTP id zv5so60636381lab.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 13:25:31 -0700 (PDT)
In-Reply-To: <CALnjE+pNXwAisxyZnb3Lik1ZMa_0QLvLip9TOOqLEZUbboT8BQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 1:13 PM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Sep 30, 2015 at 12:09 AM, Jiri Benc <jbenc@redhat.com> wrote:
>> On Tue, 29 Sep 2015 13:41:34 -0700, Pravin Shelar wrote:
>>> We can add rather add TUNNEL_IPV6 flag to distinguish IPv4 and IPv6
>>> tunnel keys. This can be stored in ip_tunnel_key.tun_flags.
>>
>> Not really. This was my original approach, too, but openvswitch is not
>> the only user of struct ip_tunnel_key, and in the lwtunnel core,
>> tun_flags are handled in the way that makes this impractical. Most
>> importantly, the tun_flags value is directly taken from/stored to
>> LWTUNNEL_IP_FLAGS/LWTUNNEL_IP6_FLAGS netlink attributes in
>> net/ipv4/ip_tunnel_core.c. This would mean complicated masking, etc.
>>
> How is it impractical ? Userspace can set flag for IPv6 tunnel info.
> That should be easy.
>
> IPv6 bit can not be masked anyways so I do not see problem with
> masking this flag due to the new bit.

I think he meant for non-OVS users.

> Since this field is exposed to userspace. TUNNEL_* flags needs to be
> moved to uapi header.

This doesn't really seem all that desirable to me. It's nice to be
able to change these as necessary and in the particular case of IPv6,
it seems like something that the kernel can manage by itself (as is
done in this patch and I think the same strategy would apply
regardless of the particular representation).
