From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 00/12] nfp: add flower app with representors
Date: Tue, 20 Jun 2017 19:13:43 +0300
Message-ID: <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f180.google.com ([74.125.82.180]:34821 "EHLO
        mail-ot0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750993AbdFTQNu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 12:13:50 -0400
Received: by mail-ot0-f180.google.com with SMTP id u13so79031170otd.2
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 09:13:44 -0700 (PDT)
In-Reply-To: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 20, 2017 at 8:51 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> this series adds a flower app to the NFP driver.
> It initialises four types of netdevs:
>
> * PF netdev - lower-device for communication of packets to device
> * PF representor netdev
> * VF representor netdevs
> * Phys port representor netdevs
>
> The PF netdev acts as a lower-device which sends and receives packets to
> and from the firmware. The representors act as upper-devices. For TX
> representors attach a metadata dst to the skb which is used by the PF
> netdev to prepend metadata to the packet before forwarding the firmware. On
> RX the PF netdev looks up the representor based on the prepended metadata
> recieved from the firmware and forwards the skb to the representor after
> removing the metadata.

Hi Simon, Jakub

Good to have more VF representors around...

> Control queues are used to send and receive control messages which are
> used to communicate configuration information with the firmware. These
> are in separate vNIC to the queues belonging to the PF netdev. The control
> queues are not exposed to use-space via a netdev or any other means.



Do you have documentation for the control channel or I should look on
earlier commits?

The control messages you describe here are also the ones that are used
to load/unload
specific app?

> As the name implies this app is targeted at providing offload of TC flower.
> That will be added by follow-up work. This patchset focuses on adding phys
> port and VF representor netdevs to which flower classifiers may be attached.

I guess you want to have switch ID so if someone looks on the reps (ip -d)
they can realize they all belong to the same e-switch, we are using
switchdev attribute for that matter.

Few nits from building from static checker below.

Or.

drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:78:1: warning:
symbol 'nfp_repr_phy_port_get_stats64' was not declared. Should it be
static?
drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:98:1: warning:
symbol 'nfp_repr_vf_get_stats64' was not declared. Should it be
static?
drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:118:1: warning:
symbol 'nfp_repr_pf_get_stats64' was not declared. Should it be
static?
drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:262:40: warning:
incorrect type in assignment (different base types)
drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:262:40:    expected
unsigned int [unsigned] [usertype] port_id
drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:262:40:    got
restricted __be32 [usertype] <noident>
drivers/net/ethernet/netronome/nfp/flower/main.c:116:19: warning: cast
to restricted __be32
