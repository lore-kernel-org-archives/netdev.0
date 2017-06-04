From: =?UTF-8?B?5byg6IOc5Li+?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next] openvswitch: add macro MODULE_ALIAS_VPORT_TYPE for vport type alias
Date: Sun, 4 Jun 2017 16:12:42 +0800
Message-ID: <000a01d2dd0a$57b46fa0$071d4ee0$@cmss.chinamobile.com>
References: <1496497655-24810-1-git-send-email-zhangshengju@cmss.chinamobile.com> <CAOrHB_CjkyEoWVJFT5Q+vPOvcg4rd9cY+z5gRi7JEQscG6-dNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "'Pravin Shelar'" <pshelar@nicira.com>,
        "'Linux Kernel Network Developers'" <netdev@vger.kernel.org>,
        "'David S. Miller'" <davem@davemloft.net>
To: "'Pravin Shelar'" <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:14314 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751204AbdFDIMs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 04:12:48 -0400
In-Reply-To: <CAOrHB_CjkyEoWVJFT5Q+vPOvcg4rd9cY+z5gRi7JEQscG6-dNg@mail.gmail.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Pravin Shelar [mailto:pshelar@ovn.org]
> Sent: Sunday, June 04, 2017 1:58 PM
> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Cc: Pravin Shelar <pshelar@nicira.com>; Linux Kernel Network Developers
> <netdev@vger.kernel.org>; David S. Miller <davem@davemloft.net>
> Subject: Re: [net-next] openvswitch: add macro
> MODULE_ALIAS_VPORT_TYPE for vport type alias
> 
> On Sat, Jun 3, 2017 at 6:47 AM, Zhang Shengju
> <zhangshengju@cmss.chinamobile.com> wrote:
> > Add a new macro MODULE_ALIAS_VPORT_TYPE to unify and simplify the
> > declaration of vport type alias, and replace magic numbers with
> > symbolic constants.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  net/openvswitch/vport-geneve.c | 2 +-
> >  net/openvswitch/vport-gre.c    | 2 +-
> >  net/openvswitch/vport-vxlan.c  | 2 +-
> >  net/openvswitch/vport.h        | 3 +++
> >  4 files changed, 6 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/openvswitch/vport-geneve.c
> > b/net/openvswitch/vport-geneve.c index 5aaf3ba..1c068d6 100644
> > --- a/net/openvswitch/vport-geneve.c
> > +++ b/net/openvswitch/vport-geneve.c
> > @@ -141,4 +141,4 @@ static void __exit ovs_geneve_tnl_exit(void)
> >
> >  MODULE_DESCRIPTION("OVS: Geneve switching port");
> > MODULE_LICENSE("GPL"); -MODULE_ALIAS("vport-type-5");
> > +MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GENEVE);
> > diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
> > index 0e72d95..48a5852 100644
> > --- a/net/openvswitch/vport-gre.c
> > +++ b/net/openvswitch/vport-gre.c
> > @@ -113,4 +113,4 @@ static void __exit ovs_gre_tnl_exit(void)
> >
> >  MODULE_DESCRIPTION("OVS: GRE switching port");
> > MODULE_LICENSE("GPL"); -MODULE_ALIAS("vport-type-3");
> > +MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GRE);
> 
> This is user visible change. For example this is changing the gre
> module alias from "vport-type-3" to "vport-type-OVS_VPORT_TYPE_GRE".
> This could break userspace application.
Hi Shelar,
Actually this change does not change module alias name. I use '__stringify' to 
address this.  Below is my build result:
```
[zhangshengju@promote net-next]$ modinfo net/openvswitch/vport-gre.ko 
filename:       /gitlab/net-next/net/openvswitch/vport-gre.ko
alias:          vport-type-3
...
```

BRs,
Zhang Shengju
