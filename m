From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 09/14] rocker: add rtnl ops for port mode [gs]etting
Date: Mon, 5 Oct 2015 08:41:29 -0700
Message-ID: <CAE4R7bA6+_WUQ5BXD54zQK7DM64P3FS5D+TdUc1gcpbjd1+oZw@mail.gmail.com>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us> <1443993949-3915-10-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35316 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbbJEPlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:41:49 -0400
Received: by obbzf10 with SMTP id zf10so131621668obb.2
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:41:48 -0700 (PDT)
In-Reply-To: <1443993949-3915-10-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 4, 2015 at 2:25 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Introduce a stub for allowing user to change rocker port world/mode.
> This is implemented using rtnl changelink op.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

[cut]

> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 3a5f263..7da768e 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -416,6 +416,17 @@ enum {
>  };
>  #define IFLA_GENEVE_MAX        (__IFLA_GENEVE_MAX - 1)
>
> +/* Rocker section */
> +enum {
> +       IFLA_ROCKER_UNSPEC,
> +       IFLA_ROCKER_MODE,
> +       __IFLA_ROCKER_MAX,
> +};
> +
> +#define IFLA_ROCKER_MAX        (__IFLA_ROCKER_MAX - 1)
> +
> +#define ROCKER_MODE_MAX 16

Does this mean there is going to be a "ip link set dev DEV type rocker
mode MODE" command option?

It doesn't seem right to be adding driver-specific IFLA_'s here.  I
think this sets bad precedence for other drivers to add their own
knobs without thinking about a generic shared mechanism.

Actually, I don't see the point of letting the user dynamically change
the port mode.  I would prefer this knob be moved to qemu/rocker.  Let
the port mode be specified on device creation.

-scott
