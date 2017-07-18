From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 04/11] net: dsa: Add support for learning FDB through notification
Date: Tue, 18 Jul 2017 13:16:58 -0400
Message-ID: <87o9shfywl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1500387624-4361-1-git-send-email-arkadis@mellanox.com> <1500387624-4361-5-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49316 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751363AbdGRRTl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 13:19:41 -0400
In-Reply-To: <1500387624-4361-5-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arkadi,

Arkadi Sharshevsky <arkadis@mellanox.com> writes:

> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -451,6 +451,7 @@ void unregister_switch_driver(struct dsa_switch_driver *type);
>  struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
>  
>  struct net_device *dsa_dev_to_net_device(struct device *dev);
> +bool dsa_schedule_work(struct work_struct *work);

You forgot to move this declaration to net/dsa/dsa_priv.h, since this is
private to DSA core and does not need to be exposed to drivers ;-)

> +	err = unregister_netdevice_notifier(&dsa_slave_switchdev_notifier);
> +	if (err)
> +		pr_err("DSA: failed to unregister switchdev notifier (%d)\n", err);

I think you meant unregister_switchdev_notifier() here.

Thanks,

        Vivien
