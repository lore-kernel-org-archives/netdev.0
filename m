From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next] geneve: always fill CSUM6_RX configuration
Date: Mon, 22 May 2017 12:50:46 -0400
Message-ID: <20170522165046.GQ9969@rhel7>
References: <20170518195956.12686-1-e@erig.me>
 <CAOrHB_CKLgriV3XjG1fBHvyB9GQQ3GXOT8+ggmtLXFz3cvj56Q@mail.gmail.com>
 <20170520133503.GM9969@rhel7>
 <CAOrHB_BnX9P9ONLvZcBj+M2_ZbOyGqtu+nYNuP5XBtJc2yUfMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59316 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758272AbdEVQuy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 12:50:54 -0400
Content-Disposition: inline
In-Reply-To: <CAOrHB_BnX9P9ONLvZcBj+M2_ZbOyGqtu+nYNuP5XBtJc2yUfMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 20, 2017 at 09:56:44PM -0700, Pravin Shelar wrote:
> On Sat, May 20, 2017 at 6:35 AM, Eric Garver <e@erig.me> wrote:
> > On Fri, May 19, 2017 at 06:57:46PM -0700, Pravin Shelar wrote:
> >> On Thu, May 18, 2017 at 12:59 PM, Eric Garver <e@erig.me> wrote:
> >> > CSMU6_RX is relevant for collect_metadata as well. As such leave it
> >> > outside of the dev's IPv4/IPv6 checks.
> >> >
> >> Can you explain it bit? is this flag used with ipv4 tunnels?
> >
> > It's used with collect_metadata as both ipv4 and ipv6 sockets will be
> > created.
> >
> > openvswitch recently gained support for creating tunnels with rtnetlink.
> > It sets COLLECT_METADATA and CSUM6_RX. After create, it does a get to
> > verify the device got created with all the requested configuration. The
> > verify was failing due to CSUM6_RX not being returned.
> >
> > Since ip_tunnel_info_af() defaults to returning AF_INET, we fall into
> > the IPv4 case and CSUM6_RX is never returned. Other relevant areas that
> > call ip_tunnel_info_af() do so using the info from the skb, not the
> > geneve_dev.
> >
> ok.
> I think ip_tunnel_info_af() check is not right. it does not work in
> case of collect_metadata.
> Better fix would be check for genene->sock4 and genene->sock6 and
> build the netlink skb accordingly.

Agreed. That's a better idea.

Lets drop this patch. I'll work on one to look at the actual sockets
instead.

Thanks Pravin.
