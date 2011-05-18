From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 2/2] bna: Add Generic Netlink Interface
Date: Wed, 18 May 2011 14:00:05 +0200
Message-ID: <20110518120005.GC3762520@jupiter.n2.diac24.net>
References: <1305694621-28023-1-git-send-email-rmody@brocade.com>
 <1305694621-28023-3-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com,
	Debashis Dutt <ddutt@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:57633 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932964Ab1ERMAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2011 08:00:13 -0400
Content-Disposition: inline
In-Reply-To: <1305694621-28023-3-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2011 at 09:57:01PM -0700, Rasesh Mody wrote:
> This patch adds the generic netlink communication interface to BNA driver. The
> in-kernel generic netlink infrastructure can be used to collect hardware
> specific control information and control attributes. The driver makes use of
> the "doit" handler provided by the generic netlink layer to accomplish this.
[...]
> +struct bnad_genl_ioc_info {
> +	int		status;
> +	u16		bnad_num;
> +	u16		rsvd;
> +	char		serialnum[64];
> +	char		hwpath[BFA_STRING_32];
> +	char		adapter_hwpath[BFA_STRING_32];
> +	char		guid[BFA_ADAPTER_SYM_NAME_LEN*2];
> +	char		name[BFA_ADAPTER_SYM_NAME_LEN];
> +	char		port_name[BFA_ADAPTER_SYM_NAME_LEN];
> +	char		eth_name[BFA_ADAPTER_SYM_NAME_LEN];
> +	u64		rsvd1[4];
> +	mac_t		mac;
> +	mac_t		factory_mac;	/* Factory mac address */
> +	mac_t		current_mac;	/* Currently assigned mac address */
> +	enum bfa_ioc_type     ioc_type;
> +	u16		pvid;		/* Port vlan id */
> +	u16		rsvd2;
> +	u32		host;
> +	u32		bandwidth;	/* For PF support */
> +	u32		rsvd3;
> +};
> +
> +struct bnad_genl_ioc_attr {
> +	int		status;
> +	u16		bnad_num;
> +	u16		rsvd;
> +	struct bfa_ioc_attr  ioc_attr;
> +};

These things all look like they're better put into sysfs. Why would you
create a genl protocol just to query some presumably static attributes?


-David

