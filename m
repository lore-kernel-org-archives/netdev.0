From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 03/16] wl1251: add sysfs interface for bluetooth
 coexistence mode configuration
Date: Mon, 28 Oct 2013 23:39:47 +0000
Message-ID: <1383003587.3779.49.camel@bwh-desktop.uk.level5networks.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <1382819655-30430-4-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <freemangordon@abv.bg>,
	<aaro.koskinen@iki.fi>, <pavel@ucw.cz>, <sre@ring0.de>,
	<joni.lapilainen@gmail.com>, David Gnedt <david.gnedt@davizone.at>
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-4-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-10-26 at 22:34 +0200, Pali Roh=C3=A1r wrote:
> From: David Gnedt <david.gnedt@davizone.at>
>=20
> Port the bt_coex_mode sysfs interface from wl1251 driver version incl=
uded
> in the Maemo Fremantle kernel to allow bt-coexistence mode configurat=
ion.
> This enables userspace applications to set one of the modes
> WL1251_BT_COEX_OFF, WL1251_BT_COEX_ENABLE and WL1251_BT_COEX_MONOAUDI=
O.
> The default mode is WL1251_BT_COEX_OFF.
> It should be noted that this driver always enabled bt-coexistence bef=
ore
> and enabled bt-coexistence directly affects the receiving performance=
,
> rendering it unusable in some low-signal situations. Especially monit=
or
> mode is affected very badly with bt-coexistence enabled.
[...]

This should be implemented consistently with other drivers:

drivers/net/wireless/ath/ath9k/htc_drv_init.c:module_param_named(btcoex=
_enable, ath9k_htc_btcoex_enable, int, 0444);
drivers/net/wireless/ath/ath9k/init.c:module_param_named(btcoex_enable,=
 ath9k_btcoex_enable, int, 0444);
drivers/net/wireless/b43/main.c:module_param_named(btcoex, modparam_btc=
oex, int, 0444);
drivers/net/wireless/ipw2x00/ipw2200.c:module_param(bt_coexist, int, 04=
44);
drivers/net/wireless/iwlegacy/common.c:module_param(bt_coex_active, boo=
l, S_IRUGO);
drivers/net/wireless/iwlwifi/iwl-drv.c:module_param_named(bt_coex_activ=
e, iwlwifi_mod_params.bt_coex_active,
drivers/net/wireless/ti/wlcore/sysfs.c:static DEVICE_ATTR(bt_coex_state=
, S_IRUGO | S_IWUSR,

Oh, hmm, I see a problem here.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
