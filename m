From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 00/12] nfp: add flower app with representors
Date: Tue, 20 Jun 2017 21:19:11 +0200
Message-ID: <20170620191910.GA924@vergenet.net>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:32943 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751002AbdFTTTQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:19:16 -0400
Received: by mail-wr0-f169.google.com with SMTP id r103so104072921wrb.0
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 12:19:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 20, 2017 at 07:13:43PM +0300, Or Gerlitz wrote:
> On Tue, Jun 20, 2017 at 8:51 AM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > this series adds a flower app to the NFP driver.
> > It initialises four types of netdevs:
> >
> > * PF netdev - lower-device for communication of packets to device
> > * PF representor netdev
> > * VF representor netdevs
> > * Phys port representor netdevs
> >
> > The PF netdev acts as a lower-device which sends and receives packets to
> > and from the firmware. The representors act as upper-devices. For TX
> > representors attach a metadata dst to the skb which is used by the PF
> > netdev to prepend metadata to the packet before forwarding the firmware. On
> > RX the PF netdev looks up the representor based on the prepended metadata
> > recieved from the firmware and forwards the skb to the representor after
> > removing the metadata.
> 
> Hi Simon, Jakub
> 
> Good to have more VF representors around...
> 
> > Control queues are used to send and receive control messages which are
> > used to communicate configuration information with the firmware. These
> > are in separate vNIC to the queues belonging to the PF netdev. The control
> > queues are not exposed to use-space via a netdev or any other means.
> 
> 
> 
> Do you have documentation for the control channel or I should look on
> earlier commits?

I don't believe there is any publicly available documentation
other than the code.

> The control messages you describe here are also the ones that are used
> to load/unload
> specific app?

In this patchset PORTMOD messages are used for (app-specific) configuration.

> > As the name implies this app is targeted at providing offload of TC flower.
> > That will be added by follow-up work. This patchset focuses on adding phys
> > port and VF representor netdevs to which flower classifiers may be attached.
> 
> I guess you want to have switch ID so if someone looks on the reps (ip -d)
> they can realize they all belong to the same e-switch, we are using
> switchdev attribute for that matter.

Yes, that intended to be part of follow-up patches.

> Few nits from building from static checker below.

Thanks, sorry for letting that through.
I'll fix them up ASAP.

> Or.
> 
> drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:78:1: warning:
> symbol 'nfp_repr_phy_port_get_stats64' was not declared. Should it be
> static?
> drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:98:1: warning:
> symbol 'nfp_repr_vf_get_stats64' was not declared. Should it be
> static?
> drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:118:1: warning:
> symbol 'nfp_repr_pf_get_stats64' was not declared. Should it be
> static?
> drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:262:40: warning:
> incorrect type in assignment (different base types)
> drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:262:40:    expected
> unsigned int [unsigned] [usertype] port_id
> drivers/net/ethernet/netronome/nfp/nfp_net_repr.c:262:40:    got
> restricted __be32 [usertype] <noident>
> drivers/net/ethernet/netronome/nfp/flower/main.c:116:19: warning: cast
> to restricted __be32
