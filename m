From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 7/7] vxlan: Add support for UDP checksums (v4 TX, v6 zero csums)
Date: Thu, 29 May 2014 15:45:19 -0700
Message-ID: <CAEP_g=9tvWCZ32HKsN0bpn-qxTcgPS8PupSRi5S0h665VDpEoQ@mail.gmail.com>
References: <alpine.DEB.2.02.1405282114100.7294@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:56964 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751573AbaE2Wpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 18:45:40 -0400
Received: by mail-qg0-f44.google.com with SMTP id i50so3026862qgf.17
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 15:45:39 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1405282114100.7294@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2014 at 9:24 PM, Tom Herbert <therbert@google.com> wrote:
> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
> index a93efa3..0edbd95 100644
> --- a/net/openvswitch/vport-vxlan.c
> +++ b/net/openvswitch/vport-vxlan.c
> @@ -122,7 +122,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
>         vxlan_port = vxlan_vport(vport);
>         strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
>
> -       vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, false);
> +       vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, 0);

OVS actually already has support for specifying that checksums should
be calculated/verified plumbed down to the kernel. This is used
already with GRE (via the TUNNEL_CSUM flag). If we modeled VXLAN
similarly then it might make the two protocols more similar and give
us OVS support for free.
