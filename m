From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses dev_addr_list
Date: Wed, 15 Apr 2009 16:26:04 +0800
Message-ID: <49E59A1C.9030108@cn.fujitsu.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090415081720.GA21342@psychotron.englab.brq.redhat.com> <20090415081819.GB21342@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, dada1@cosmosbay.com,
	ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57773 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752923AbZDOIZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 04:25:17 -0400
In-Reply-To: <20090415081819.GB21342@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int __hw_addr_add_ii(struct list_head *list, unsigned char *addr,
> +			    int addr_len, int ignore_index)
> +{
> +	struct netdev_hw_addr *ha;
> +	int i = 0;
> +
> +	if (addr_len > MAX_ADDR_LEN)
> +		return -EINVAL;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ha, list, list) {
> +		if (i++ != ignore_index &&
> +		    !memcmp(ha->addr, addr, addr_len)) {
> +			ha->refcount++;
> +			return 0;

missing rcu_read_unlock() ?

> +		}
> +	}
> +	rcu_read_unlock();
