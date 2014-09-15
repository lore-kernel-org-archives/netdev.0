From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next v7 0/4] Refactor vxlan and l2tp to use common UDP
 tunnel APIs
Date: Mon, 15 Sep 2014 11:41:46 -0700
Message-ID: <CACzMAJLLAMtw8CK5R_BoHh5LgvX9-7w8YpmRup16p2GcGn0RTQ@mail.gmail.com>
References: <1410777267-28237-1-git-send-email-azhou@nicira.com>
	<CAJ3xEMg84-dxP9V+3bi-_Ljen-=xUa2D+Tsnw1XW_WA6Q1=ajw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:44913 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754498AbaIOSlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 14:41:47 -0400
Received: by mail-ob0-f170.google.com with SMTP id uy5so2814054obc.15
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 11:41:46 -0700 (PDT)
In-Reply-To: <CAJ3xEMg84-dxP9V+3bi-_Ljen-=xUa2D+Tsnw1XW_WA6Q1=ajw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"expend" means I added a few more APIs to udp_tunnel.c:

setup_udp_tunnel_sock()
udp_tunnel_xmit_skb(), udp_tunnel6_xmit_skb()
udp_tunnek_sock_release()

There should be nothing beyond refactoring. Those logic exists in
vxlan and l2tp tunnel logic currently. The patch move them into their
own API so that they can be  shared.

On Mon, Sep 15, 2014 at 10:46 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 15, 2014 at 1:34 PM, Andy Zhou <azhou@nicira.com> wrote:
>> Andy Zhou (4):
>>   udp_tunnel: Seperate ipv6 functions into its own file.
>>   udp-tunnel: Expand UDP tunnel APIs
>>   vxlan: Refactor vxlan driver to make use of the common UDP tunnel
>>     functions.
>>   l2tp: Refactor l2tp core driver to make use of the common UDP tunnel
>>     functions
>
> In V5's cover-letter you wrote "This patch series expend current UDP
> tunnel APIs and refactoring current
> UDP tunnel based protocols to make use of the new APIs. The main motivation
> is to reduce code duplication." -- I wasn't fully sure to follow
> what's the exact meaning of "expend" in this context? do we
> have anything here that goes beyond refactoring?
>
>
>
>>
>>  drivers/net/vxlan.c       |  105 ++++++++--------------------------
>>  include/net/udp_tunnel.h  |   83 ++++++++++++++++++++++++++-
>>  net/ipv4/udp_tunnel.c     |  138 ++++++++++++++++++++++++---------------------
>>  net/ipv6/Makefile         |    1 +
>>  net/ipv6/ip6_udp_tunnel.c |  105 ++++++++++++++++++++++++++++++++++
>>  net/l2tp/l2tp_core.c      |   24 ++++----
>>  6 files changed, 292 insertions(+), 164 deletions(-)
>>  create mode 100644 net/ipv6/ip6_udp_tunnel.c
>>
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
