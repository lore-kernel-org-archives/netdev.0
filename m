From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Do not use private netdev_vport fields
Date: Tue, 6 Jan 2015 13:16:11 -0800
Message-ID: <CALnjE+odj6GdO97n4NBLQhP4egMzuNHMjxVqMwC7fSC5C=hT-g@mail.gmail.com>
References: <1420577481-20238-1-git-send-email-daniele.di.proietto@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Daniele Di Proietto <daniele.di.proietto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:32770 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750921AbbAFVQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 16:16:12 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so4824314igb.1
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 13:16:11 -0800 (PST)
In-Reply-To: <1420577481-20238-1-git-send-email-daniele.di.proietto@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 12:51 PM, Daniele Di Proietto
<daniele.di.proietto@gmail.com> wrote:
> This commit introduces netdev_vport_index() to prevent datapath.c from directly accessing the 'dev' member of 'struct netdev_vport'.
> This fix is needed to allow possible alternative netdev_vport implementations.
>
> Signed-off-by: Daniele Di Proietto <daniele.di.proietto@gmail.com>
> ---
>  net/openvswitch/datapath.c     | 2 +-
>  net/openvswitch/vport-netdev.h | 6 ++++++
>  2 files changed, 7 insertions(+), 1 deletion(-)
>
...
>
> diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
> index 6f7038e..ecfcbd5 100644
> --- a/net/openvswitch/vport-netdev.h
> +++ b/net/openvswitch/vport-netdev.h
> @@ -38,6 +38,12 @@ netdev_vport_priv(const struct vport *vport)
>         return vport_priv(vport);
>  }
>
> +static inline int
> +netdev_vport_index(const struct vport *vport)
> +{
> +       return netdev_vport_priv(vport)->dev->ifindex;
> +}
> +
Function return type and function name should be on same line,
otherwise looks good.

>  const char *ovs_netdev_get_name(const struct vport *);
>  void ovs_netdev_detach_dev(struct vport *);
>
> --
> 2.1.4
>
