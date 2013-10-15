From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v3 net-next] openvswitch: fix vport-netdev unregister
Date: Tue, 15 Oct 2013 08:31:18 -0700
Message-ID: <CAEP_g=-hkjjph8qO8MQL=BBA8MnaUdE2vTy3jN+m7Vh5skfa6g@mail.gmail.com>
References: <1381722652-3689-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Pirko <jiri@resnulli.us>, Cong Wang <amwang@redhat.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:52788 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932822Ab3JOPbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 11:31:39 -0400
Received: by mail-ie0-f175.google.com with SMTP id aq17so12910848iec.6
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 08:31:38 -0700 (PDT)
In-Reply-To: <1381722652-3689-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 13, 2013 at 8:50 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
> index c323567..ffa429a 100644
> --- a/net/openvswitch/dp_notify.c
> +++ b/net/openvswitch/dp_notify.c
> @@ -59,15 +59,9 @@ void ovs_dp_notify_wq(struct work_struct *work)
>                         struct hlist_node *n;
>
>                         hlist_for_each_entry_safe(vport, n, &dp->ports[i], dp_hash_node) {
> -                               struct netdev_vport *netdev_vport;
> -
>                                 if (vport->ops->type != OVS_VPORT_TYPE_NETDEV)
>                                         continue;
> -
> -                               netdev_vport = netdev_vport_priv(vport);
> -                               if (netdev_vport->dev->reg_state == NETREG_UNREGISTERED ||
> -                                   netdev_vport->dev->reg_state == NETREG_UNREGISTERING)
> -                                       dp_detach_port_notify(vport);
> +                               dp_detach_port_notify(vport);

Doesn't this free *all* ports of type OVS_VPORT_TYPE_NETDEV when any
one of them is removed?
