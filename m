From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH wireless-next] brcmsmac: avoid 512 byte stack variable
Date: Thu, 07 Feb 2013 12:19:46 -0800
Message-ID: <1360268386.27863.2.camel@joe-AO722>
References: <1360268032-52414-1-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360268032-52414-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-02-07 at 13:13 -0700, Tim Gardner wrote:
> Dynamically allocate the probe response template which
> avoids potential stack corruption. Observed with smatch:

trivial:

> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
[]
> @@ -7408,9 +7408,16 @@ brcms_c_bss_update_probe_resp(struct brcms_c_info *wlc,
[]
> +	prb_resp = kmalloc(BCN_TMPL_LEN, GFP_ATOMIC);
> +	if (!prb_resp) {
> +		wiphy_err(wlc->wiphy, "wl: %s: failed to alloc %u bytes\n",
> +			__func__, BCN_TMPL_LEN);

Please remove the error message.
alloc's don't need specific OOM messages.

The mm subsystem already provides a standardized
message with a dump_stack().
