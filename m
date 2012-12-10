From: saeed bishara <saeed.bishara@gmail.com>
Subject: Re: [PATCH v4 1/5] net: Add support for hardware-offloaded encapsulation
Date: Mon, 10 Dec 2012 12:04:15 +0200
Message-ID: <CAMAG_ee6xW4EnzPFt=_5+NL2+LuyUjxd52Xc242inYm2+Yhg7g@mail.gmail.com>
References: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com> <1354925658-24115-2-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	gospo@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dmitry@broadcom.com,
	bhutchings@solarflare.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354925658-24115-2-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static inline struct iphdr *inner_ip_hdr(const struct sk_buff *skb)
> +{
> +       return (struct iphdr *)skb_inner_network_header(skb);
> +}

Hi,
I'm a little bit bothered because of those inner_ functions, what
about the following approach:
1. the skb will have a new state, that state can be outer (normal
mode) and inner.
2. when you change the state to inner, all the helper functions such
as ip_hdr will return the innter header.

that's ofcourse the API side. the implementation may still use the
fields you added to the skb.

what you think?
saeed
