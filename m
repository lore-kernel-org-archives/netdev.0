From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] net: Adding support for Cavium
 ThunderX network controller
Date: Mon, 18 May 2015 16:09:31 -0400 (EDT)
Message-ID: <20150518.160931.2235555994068443513.davem@davemloft.net>
References: <1431747401-20847-1-git-send-email-aleksey.makarov@auriga.com>
	<1431747401-20847-3-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	david.daney@cavium.com, sgoutham@cavium.com, mjc@semihalf.com,
	ganapatrao.kulkarni@caviumnetworks.com, tomasz.nowicki@linaro.org,
	rrichter@cavium.com, kamil@semihalf.com,
	tsrinivasulu@caviumnetworks.com, svangala@cavium.com,
	rric@kernel.org, linux-arm-kernel@lists.infradead.org
To: aleksey.makarov@auriga.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431747401-20847-3-git-send-email-aleksey.makarov@auriga.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aleksey Makarov <aleksey.makarov@auriga.com>
Date: Fri, 15 May 2015 20:36:39 -0700

> +/* Register read/write APIs */
> +static void nic_reg_write(struct nicpf *nic, u64 offset, u64 val)
> +{
> +	writeq_relaxed(val, nic->reg_base + offset);
> +}
> +
> +static u64 nic_reg_read(struct nicpf *nic, u64 offset)
> +{
> +	return readq_relaxed(nic->reg_base + offset);
> +}

Are you really sure it's OK to used relaxed ordering for all register
accesses like this?

Personally, I think it's asking for trouble.

Maybe in _extremely_ specific situations in the packet processing
fast path where you can clearly define the ordering needs when
programming the mailbox registers, I'd say it's OK.

But universally across the entire driver?  No way, no way at all.
