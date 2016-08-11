From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net 2/4] hv_netvsc: reset vf_inject on VF removal
Date: Thu, 11 Aug 2016 11:46:18 +0000
Message-ID: <CO2PR11MB008839DC3A61A4F211CC148F971E0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
 <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static void netvsc_inject_enable(struct net_device_context
> +*net_device_ctx) {
> +	net_device_ctx->vf_inject = true;
> +}
> +
> +static void netvsc_inject_disable(struct net_device_context
> +*net_device_ctx) {
> +	net_device_ctx->vf_inject = false;
> +
> +	/* Wait for currently active users to drain out. */
> +	while (atomic_read(&net_device_ctx->vf_use_cnt) != 0)
> +		udelay(50);
> +}

That was already the behavior before, but are you certain you
want to unconditionally block without any possible timeout?
