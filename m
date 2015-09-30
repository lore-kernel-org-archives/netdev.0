From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/2] openvswitch: add tunnel protocol to sw_flow_key
Date: Wed, 30 Sep 2015 13:13:56 -0700
Message-ID: <CALnjE+pNXwAisxyZnb3Lik1ZMa_0QLvLip9TOOqLEZUbboT8BQ@mail.gmail.com>
References: <cover.1443548447.git.jbenc@redhat.com>
	<428cee4cb7e04cfea5bef90b37d257562ea78a83.1443548447.git.jbenc@redhat.com>
	<CALnjE+qWmENWj_hL87++Sk=zzrvj2U0VAEW26ySAjg5RsDymuA@mail.gmail.com>
	<20150930090946.4e4bb610@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36648 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932506AbbI3UN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 16:13:57 -0400
Received: by ioii196 with SMTP id i196so61382273ioi.3
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 13:13:56 -0700 (PDT)
In-Reply-To: <20150930090946.4e4bb610@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 12:09 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 29 Sep 2015 13:41:34 -0700, Pravin Shelar wrote:
>> We can add rather add TUNNEL_IPV6 flag to distinguish IPv4 and IPv6
>> tunnel keys. This can be stored in ip_tunnel_key.tun_flags.
>
> Not really. This was my original approach, too, but openvswitch is not
> the only user of struct ip_tunnel_key, and in the lwtunnel core,
> tun_flags are handled in the way that makes this impractical. Most
> importantly, the tun_flags value is directly taken from/stored to
> LWTUNNEL_IP_FLAGS/LWTUNNEL_IP6_FLAGS netlink attributes in
> net/ipv4/ip_tunnel_core.c. This would mean complicated masking, etc.
>
How is it impractical ? Userspace can set flag for IPv6 tunnel info.
That should be easy.

IPv6 bit can not be masked anyways so I do not see problem with
masking this flag due to the new bit.

Since this field is exposed to userspace. TUNNEL_* flags needs to be
moved to uapi header.


>> That also saves space in flow key.
>
> The field was added to a 2 byte hole in the struct sw_flow_key (leaving
> still 1 byte free), thus there's no additional space used.
>
>  Jiri
>
> --
> Jiri Benc
