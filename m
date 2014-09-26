From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v3 5/7] net: Add GSO support for UDP tunnels with checksum
Date: Fri, 26 Sep 2014 14:57:28 -0700
Message-ID: <CA+mtBx-FqE70TROzxi=-B9DKaUsMs-=KZk3XbY7_qhOk3b2aNQ@mail.gmail.com>
References: <alpine.DEB.2.02.1406041706450.14949@tomh.mtv.corp.google.com>
	<CAJZOPZJTfJtuhWZ91_KOZxr=V7J7KPX5OGeR_7rY52iOjWcEVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:52032 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756040AbaIZV53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:57:29 -0400
Received: by mail-ie0-f173.google.com with SMTP id lx4so887656iec.32
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 14:57:29 -0700 (PDT)
In-Reply-To: <CAJZOPZJTfJtuhWZ91_KOZxr=V7J7KPX5OGeR_7rY52iOjWcEVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 2:05 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Thu, Jun 5, 2014 at 3:20 AM, Tom Herbert <therbert@google.com> wrote:
>>
>> Added a new netif feature for GSO_UDP_TUNNEL_CSUM. This indicates
>> that a device is capable of computing the UDP checksum in the
>> encapsulating header of a UDP tunnel.
>
>
>
> Tom,
>
> Do we have upstream driver that supports GSO_UDP_TUNNEL_CSUM? did you
> had such driver/patch while doing this patches? when a driver
> advertizes that bit, should they look over the xmit path on the new
> encap_hdr_csum bit?
>
No, no, and encap_hdr_csum should only be set with
SKB_GSO_UDP_TUNNEL_CSUM or SKB_GSO_GRE_CSUM.

find . -name '*.[ch]' -exec fgrep -l GSO_UDP_TUNNEL_CSUM {} \;

returns nothing.

find . -name '*.[ch]' -exec fgrep -l GSO_UDP_TUNNEL {} \;

returns

./ethernet/intel/i40e/i40e_main.c
./ethernet/broadcom/bnx2x/bnx2x_main.c
./ethernet/qlogic/qlcnic/qlcnic_main.c
./ethernet/mellanox/mlx4/en_netdev.c
./ethernet/emulex/benet/be_main.c

> Or.
>
>
>>
>>  include/linux/netdev_features.h |  1 +
>>  include/linux/skbuff.h          |  2 ++
>>  net/ipv4/af_inet.c              |  1 +
>>  net/ipv4/tcp_offload.c          |  1 +
>>  net/ipv4/udp.c                  | 40 +++++++++++++++++++---------------------
>>  net/ipv4/udp_offload.c          |  4 +++-
>>  net/ipv6/ip6_offload.c          |  1 +
>>  net/ipv6/udp_offload.c          |  4 +++-
>>  8 files changed, 31 insertions(+), 23 deletions(-)
