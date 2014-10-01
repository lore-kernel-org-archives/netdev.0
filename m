From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: dsa: Fix build warning for !PM_SLEEP
Date: Wed, 1 Oct 2014 09:19:24 -0300
Message-ID: <CAOMZO5DJrvO=mpUEqk+GWFGGU_eNEfn=+XkoL6cqYv+c4GSyZw@mail.gmail.com>
References: <1412164740-32452-1-git-send-email-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Thierry Reding <thierry.reding@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:38691 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbaJAMT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 08:19:26 -0400
In-Reply-To: <1412164740-32452-1-git-send-email-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 8:59 AM, Thierry Reding <thierry.reding@gmail.com> wrote:
> From: Thierry Reding <treding@nvidia.com>
>
> The dsa_switch_suspend() and dsa_switch_resume() functions are only used
> when PM_SLEEP is enabled, so they need #ifdef CONFIG_PM_SLEEP protection
> to avoid a compiler warning.
>
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
>  net/dsa/dsa.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 6905f2d84c44..22f34cf4cb27 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -238,6 +238,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
>  {
>  }
>
> +#ifdef CONFIG_PM_SLEEP
>  static int dsa_switch_suspend(struct dsa_switch *ds)
>  {
>         int i, ret = 0;
> @@ -280,6 +281,7 @@ static int dsa_switch_resume(struct dsa_switch *ds)
>
>         return 0;
>  }
> +#endif

You could also mark them as __maybe_unused and avoid the ifdef.
