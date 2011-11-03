From: Nick Carter <ncarter100@gmail.com>
Subject: Re: bridge: allow forwarding LLDP frames
Date: Thu, 3 Nov 2011 22:17:48 +0000
Message-ID: <CAEJpZP2oGUYW_i+7qYxyD8th_YdGo5+nZaevceYJJxGWsR5c2w@mail.gmail.com>
References: <20111017181207.06081E3280@meep>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org
To: Ed Swierk <eswierk@bigswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:38091 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873Ab1KCWRt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 18:17:49 -0400
Received: by pzk2 with SMTP id 2so4816549pzk.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2011 15:17:48 -0700 (PDT)
In-Reply-To: <20111017181207.06081E3280@meep>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 October 2011 19:12, Ed Swierk <eswierk@bigswitch.com> wrote:
> LLDP frames have reserved destination MAC address 01-80-C2-00-00-0E,
> which by default are not forwarded by 802.1d-compliant bridges.
>
> In certain situations, like when creating a transparent link-layer
> relay between a pair of interfaces, it may be useful to configure a
> bridge interface to forward LLDP and other control frames in the
> 01-80-C2-00-00-xx range rather than filtering them.
>
> Stephen Hemminger's recent patch allows the user to set a sysfs
> attribute /sys/class/net/brX/bridge/group_fwd_mask to enable
> forwarding of normally filtered addresses, with certain exceptions.
> This patch eliminates the restriction on LLDP frames, allowing the
> user to override the default behavior of filtering them.

The reason the group fwd mask was introduced was to make the bridge
forward link local group addresses.  This is non standards based
behaviour.  The point of the group fwd mask is so that users can have
non standard bridging behaviour.

I don't understand why the recent commit includes blocking the user
from choosing to forward certain groups because it breaks standards ?
The default mask of 0 is standards based behaviour.  If the user sets
it to anything other than 0 then they want non standards based
behaviour.

In my view the behaviour now is very confusing for the user.  802.1X
is allowed to be forwarded but LLDP forwarding is rejected ?

The group fwd mask should be allowed to be set to any value.  This
would give flexible and predictable behaviour to the user.

I think we should assume users know the behaviour they require and
BR_GROUPFWD_RESTRICTED should be removed from the codebase.

Nick

>
> Signed-off-by: Ed Swierk <eswierk@bigswitch.com>
>
> ---
>
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index a248fe6..b016dd8 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -31,8 +31,8 @@
>
> =A0/* Control of forwarding link local multicast */
> =A0#define BR_GROUPFWD_DEFAULT =A0 =A00
> -/* Don't allow forwarding control protocols like STP and LLDP */
> -#define BR_GROUPFWD_RESTRICTED 0x4007u
> +/* Don't allow forwarding control protocols like STP */
> +#define BR_GROUPFWD_RESTRICTED 0x0007u
>
> =A0/* Path to usermode spanning tree program */
> =A0#define BR_STP_PROG =A0 =A0"/sbin/bridge-stp"
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
