From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH net-next 0/9] support unique MAC addresses for slave devices
Date: Thu, 27 Apr 2017 12:21:49 -0700
Message-ID: <CAF2d9jjJ9J1B3fN3Ojkq=T5CVT-360-uY+-kpedTGr_XRcv0kw@mail.gmail.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>
To: Marco Chiappero <marco.chiappero@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:36879 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030709AbdD0TWK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 15:22:10 -0400
Received: by mail-it0-f48.google.com with SMTP id x188so21383155itb.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 12:22:10 -0700 (PDT)
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 7:51 AM, Marco Chiappero
<marco.chiappero@intel.com> wrote:
> Currently every slave device gets assigned the same MAC address, by
> having it copied from the master interface. Since some code paths
> depend on this identity, changing the MAC address on slave interfaces
> is not supported. However identical MAC addresses can pose problems to
> management and orchestration software that correctly expect network
> interfaces on the same segment to have unique addresses.
>
Please understand that there are two distinct drivers IPvlan and
MACvlan. They both exist together for good reasons and are trying to
cater for different needs. I would love to combine them together if we
don't mess / miss the goodies each of them have to offer... otherwise
*NO*! Having said that if management / orchestration software has
problems then clearly you should not use IPvlan for that use case.

> Patches 1-8 include style fixes and refactoring (patch 9 depends upon)
> that improve the overal quality and make the intruduction of the
> feature straightforward.
>
Lots of this fall into I-say-potato-you-say-... category. My way of
thinking / organizing code is different than yours and you don't have
to like mine and I don't have to like yours.

> Patch 9 enables slave devices to own unique MAC addresses and change
> such addresses live, fixing lack of support and a related bug, as
> MAC address changes on master were not propagated to slave devices.
> In order to preserve the main peculiarity of this driver, that is
> exposing only a single MAC address for outbound traffic, frames
> egressing from master are now effectively masquerated when working in
> L2 mode.
>
This enhancement is, however, coming via packet-header rewrite for
every Tx/Rx packet which defeats the purpose. The only good thing that
came in light is the mac-addr change propagation from master issue;
but if the fix is coming as a side-effect of header rewrite then it's
not an acceptable fix either. This can be simply fixed by changing a
line in ipvlan_hard_header().

> Marco Chiappero (9):
>   ipvlan: fix coding style for the ipvlan tree
>   ipvlan: refactor ipvlan_process_multicast for readability
>   ipvlan: replace ipvlan_rcv_frame
>   ipvlan: rework the IP lookup function
>   ipvlan: improve and uniform naming
>   ipvlan: reposition three functions
>   ipvlan: relocate ipvlan_skb_crossing_ns calls
>   ipvlan: improve compiler hints
>   ipvlan: introduce individual MAC addresses
>
>  drivers/net/ipvlan/ipvlan.h      |   2 +-
>  drivers/net/ipvlan/ipvlan_core.c | 592 ++++++++++++++++++++-------------------
>  drivers/net/ipvlan/ipvlan_main.c |  49 ++--
>  drivers/net/ipvlan/ipvtap.c      |   1 +
>  4 files changed, 333 insertions(+), 311 deletions(-)
>
> --
> 2.9.3
>
> --------------------------------------------------------------
> Intel Research and Development Ireland Limited
> Registered in Ireland
> Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
> Registered Number: 308263
>
>
> This e-mail and any attachments may contain confidential material for the sole
> use of the intended recipient(s). Any review or distribution by others is
> strictly prohibited. If you are not the intended recipient, please contact the
> sender and delete all copies.
>
