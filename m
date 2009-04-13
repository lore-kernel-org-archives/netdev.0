From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] net: introduce a list of device addresses
 dev_addr_list
Date: Mon, 13 Apr 2009 15:53:35 -0700 (PDT)
Message-ID: <20090413.155335.248383596.davem@davemloft.net>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
	<20090413083729.GA23734@psychotron.englab.brq.redhat.com>
	<20090413084201.GC23734@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com, ivecera@redhat.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751622AbZDMWxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 18:53:44 -0400
In-Reply-To: <20090413084201.GC23734@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 13 Apr 2009 10:42:02 +0200

> @@ -210,6 +210,12 @@ struct dev_addr_list
>  #define dmi_users	da_users
>  #define dmi_gusers	da_gusers
>  
> +struct hw_addr {
> +	struct list_head	list;
> +	unsigned char		addr[MAX_ADDR_LEN];
> +	int			refcount;
> +};
> +

Please don't pollute the global namespace with a structure name
like this.  Use "netdev_hw_addr" or "net_hw_addr".

> +static inline int __hw_addr_add(struct list_head *list, unsigned char *addr,
> +				int addr_len)

Please let the compiler inline things as it sees fit.  These
aren't routines in some header file or anything like that.
