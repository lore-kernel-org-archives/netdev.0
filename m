From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v5 net-next 02/14] net: define gso types for IPx over IPv4
 and IPv6
Date: Mon, 16 May 2016 11:28:30 -0700
Message-ID: <CALx6S35h99gqc+K=pMEbijO_CphCNvAckb1kdOkrZi2OnsHPGQ@mail.gmail.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
	<1463355755-3481375-3-git-send-email-tom@herbertland.com>
	<CAKgT0Uc1mQwP4xoQxM9J08kyEaxKpZse5nWdctgrrmjJowebJg@mail.gmail.com>
	<CALx6S37hCkvOZ+D15MUJUXjiGa-BdfQhPG7jo498F29-7eUSsg@mail.gmail.com>
	<CAKgT0UfC6DsSFB+o+r=+gfcda-50qK0CY-2SDkshuBC=WiKLBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36291 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470AbcEPS2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:28:31 -0400
Received: by mail-io0-f177.google.com with SMTP id i75so215297964ioa.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:28:31 -0700 (PDT)
In-Reply-To: <CAKgT0UfC6DsSFB+o+r=+gfcda-50qK0CY-2SDkshuBC=WiKLBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 11:13 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Mon, May 16, 2016 at 11:07 AM, Tom Herbert <tom@herbertland.com> wrote:
>> On Mon, May 16, 2016 at 9:32 AM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> On Sun, May 15, 2016 at 4:42 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>> This patch defines two new GSO definitions SKB_GSO_IPXIP4 and
>>>> SKB_GSO_IPXIP6 along with corresponding NETIF_F_GSO_IPXIP4 and
>>>> NETIF_F_GSO_IPXIP6. These are used to described IP in IP
>>>> tunnel and what the outer protocol is. The inner protocol
>>>> can be deduced from other GSO types (e.g. SKB_GSO_TCPV4 and
>>>> SKB_GSO_TCPV6). The GSO types of SKB_GSO_IPIP and SKB_GSO_SIT
>>>> are removed (these are both instances of SKB_GSO_IPXIP4).
>>>> SKB_GSO_IPXIP6 will be used when support for GSO with IP
>>>> encapsulation over IPv6 is added.
>>>>
>>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>>> ---
>>>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  5 ++---
>>>>  drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  4 ++--
>>>>  drivers/net/ethernet/intel/i40e/i40e_main.c       |  3 +--
>>>>  drivers/net/ethernet/intel/i40e/i40e_txrx.c       |  3 +--
>>>>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |  3 +--
>>>>  drivers/net/ethernet/intel/i40evf/i40evf_main.c   |  3 +--
>>>>  drivers/net/ethernet/intel/igb/igb_main.c         |  3 +--
>>>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  3 +--
>>>>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +--
>>>>  include/linux/netdev_features.h                   | 12 ++++++------
>>>>  include/linux/netdevice.h                         |  4 ++--
>>>>  include/linux/skbuff.h                            |  4 ++--
>>>>  net/core/ethtool.c                                |  4 ++--
>>>>  net/ipv4/af_inet.c                                |  2 +-
>>>>  net/ipv4/ipip.c                                   |  2 +-
>>>>  net/ipv6/ip6_offload.c                            |  4 ++--
>>>>  net/ipv6/sit.c                                    |  4 ++--
>>>>  net/netfilter/ipvs/ip_vs_xmit.c                   | 17 +++++++----------
>>>>  18 files changed, 36 insertions(+), 47 deletions(-)
>>>
>>> It looks like you missed drivers/net/ethernet/intel/igb/netdev.c.  If
>>> you don't get it then it will break the build.
>>>
>>
>> I don't see file that in betdev branch, maybe it's new?
>
> Nope, it has been there for a while.  It got patched to support IPIP
> and SIT tunnels in the same patch that updated igb/igb_main.c.
>

Looks like it's

drivers/net/ethernet/intel/igbvf/netdev.c

> I am also looking into the other patches now.  It looks like something
> broke hardware offloads again as I am only getting .9 Mb/s for IPv6
> based GRE tunnels with your patches applied.  I'm trying to bisect it
> now.
>
What hardware are you using?

Tom

> - Alex
