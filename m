From: Gabor Juhos <juhosg-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 2/2] ath9k: Gather and report IRQ sync_cause errors.
Date: Tue, 17 Apr 2012 23:07:43 +0200
Message-ID: <4F8DDB9F.8030302@openwrt.org>
References: <1334250240-21038-1-git-send-email-greearb@candelatech.com> <1334250240-21038-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334250240-21038-2-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
>=20
> Report all defined sync_cause errors in debugfs
> to aid with debugging.
>=20
> Use a macro to print out the interrupts file contents
> to decrease code duplication.

Now, that the patch is in wireless-testing, I have noticed a minor prob=
lem with it.

>=20
> Signed-off-by: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
> ---


<...>

> diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wirele=
ss/ath/ath9k/hw.h
> index aa1680a..fba99ef 100644
> --- a/drivers/net/wireless/ath/ath9k/hw.h
> +++ b/drivers/net/wireless/ath/ath9k/hw.h
> @@ -965,6 +965,12 @@ bool ath9k_hw_check_alive(struct ath_hw *ah);
> =20
>  bool ath9k_hw_setpower(struct ath_hw *ah, enum ath9k_power_mode mode=
);
> =20
> +#ifdef CONFIG_ATH9K_DEBUGFS
> +void ath9k_debug_sync_cause(struct ath_common *common, u32 sync_caus=
e);
> +#else
> +static void ath9k_debug_sync_cause(struct ath_common *common, u32 sy=
nc_cause) {}

Due to a missing 'inline' keyword, this causes a bunch of warnings if
CONFIG_ATH9K_DEBUGFS is not enabled:

   CC [M]  drivers/net/wireless/ath/main.o
   CC [M]  drivers/net/wireless/ath/regd.o
   CC [M]  drivers/net/wireless/ath/hw.o
   CC [M]  drivers/net/wireless/ath/key.o
   LD [M]  drivers/net/wireless/ath/ath.o
   CC [M]  drivers/net/wireless/ath/ath9k/beacon.o
 drivers/net/wireless/ath/ath9k/hw.h:962: warning: =E2=80=98ath9k_debug=
_sync_cause=E2=80=99
defined but not used
   CC [M]  drivers/net/wireless/ath/ath9k/gpio.o
 drivers/net/wireless/ath/ath9k/hw.h:962: warning: =E2=80=98ath9k_debug=
_sync_cause=E2=80=99
defined but not used
   CC [M]  drivers/net/wireless/ath/ath9k/init.o
 drivers/net/wireless/ath/ath9k/hw.h:962: warning: =E2=80=98ath9k_debug=
_sync_cause=E2=80=99
defined but not used
   CC [M]  drivers/net/wireless/ath/ath9k/main.o
 drivers/net/wireless/ath/ath9k/hw.h:962: warning: =E2=80=98ath9k_debug=
_sync_cause=E2=80=99
defined but not used
   CC [M]  drivers/net/wireless/ath/ath9k/recv.o

-Gabor

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
