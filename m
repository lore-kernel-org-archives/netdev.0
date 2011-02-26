From: Vitaly Wool <vitalywool@gmail.com>
Subject: Re: [PATCH] Bluetooth: Fix BT_L2CAP and BT_SCO in Kconfig
Date: Sat, 26 Feb 2011 18:52:44 +0100
Message-ID: <AANLkTimuyx4ixPq5BexRHozebVpjry2k-2xskqVf79g1@mail.gmail.com>
References: <20110226013639.GA2166@joana>
	<1298684485-3081-1-git-send-email-padovan@profusion.mobi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linville@tuxdriver.com,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: "Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:58272 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413Ab1BZRwr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 12:52:47 -0500
In-Reply-To: <1298684485-3081-1-git-send-email-padovan@profusion.mobi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gustavo,

On Sat, Feb 26, 2011 at 2:41 AM, Gustavo F. Padovan
<padovan@profusion.mobi> wrote:
> If we want something "bool" built-in in something "tristate" it can't
> "depend on" the tristate config option.
>
> Report by DaveM:
>
> =A0 I give it 'y' just to make it happen, for both, and afterways no
> =A0 matter how many times I rerun "make oldconfig" I keep seeing thin=
gs
> =A0 like this in my build:
>
> scripts/kconfig/conf --silentoldconfig Kconfig
> include/config/auto.conf:986:warning: symbol value 'm' invalid for BT=
_SCO
> include/config/auto.conf:3156:warning: symbol value 'm' invalid for B=
T_L2CAP
>
> Reported-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
> ---
> =A0net/bluetooth/Kconfig | =A0 =A06 ++++--
> =A01 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
> index c6f9c2f..6ae5ec5 100644
> --- a/net/bluetooth/Kconfig
> +++ b/net/bluetooth/Kconfig
> @@ -31,9 +31,10 @@ menuconfig BT
> =A0 =A0 =A0 =A0 =A0to Bluetooth kernel modules are provided in the Bl=
ueZ packages. =A0For
> =A0 =A0 =A0 =A0 =A0more information, see <http://www.bluez.org/>.
>
> +if BT !=3D n
> +
> =A0config BT_L2CAP
> =A0 =A0 =A0 =A0bool "L2CAP protocol support"
> - =A0 =A0 =A0 depends on BT
> =A0 =A0 =A0 =A0select CRC16
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0L2CAP (Logical Link Control and Adaptation Protoco=
l) provides
> @@ -42,11 +43,12 @@ config BT_L2CAP
>
> =A0config BT_SCO
> =A0 =A0 =A0 =A0bool "SCO links support"
> - =A0 =A0 =A0 depends on BT
> =A0 =A0 =A0 =A0help
> =A0 =A0 =A0 =A0 =A0SCO link provides voice transport over Bluetooth. =
=A0SCO support is
> =A0 =A0 =A0 =A0 =A0required for voice applications like Headset and A=
udio.
>
> +endif
> +

Ugh, isn't it far cleaner to change initial dependencies to "depends
on BT !=3D n" ?

Thanks,
   Vitaly
