From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 13/19] qlcnic: 83xx hardware access and data path
 routines
Date: Thu, 20 Sep 2012 18:45:07 -0400 (EDT)
Message-ID: <20120920.184507.1693343817853439763.davem@davemloft.net>
References: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
	<1348098373-20745-14-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756436Ab2ITWpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 18:45:09 -0400
In-Reply-To: <1348098373-20745-14-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Wed, 19 Sep 2012 19:46:07 -0400

> +	for (i = QLCNIC_DEV_INFO_SIZE + 1;
> +		j < ARRAY_SIZE(qlcnic_83xx_reg_tbl); i++, j++)

The 'j' on the second line should be at the first column after the
openning parenthesis on the first line.

> +	ahw->intr_tbl = vmalloc(num_msix *
> +			sizeof(struct qlcnic_intrpt_config));

Same problem here.

> +	if (!(adapter->flags & QLCNIC_MSI_ENABLED) &&
> +		!(adapter->flags & QLCNIC_MSIX_ENABLED)) {

And here.

> +		if (ret) {
> +				dev_info(&adapter->pdev->dev,
> +					 "Error getting Rx stats\n");

This dev_info() call is indented one TAB too deeply.

> +	npar_info->max_mtu = le16_to_cpu(nic_info->max_mtu);
> +
> +}

Please remove this extraneous empty line.

> +		if (!((ADDR_IN_RANGE(addr, QLCNIC_ADDR_QDR_NET,
> +			QLCNIC_ADDR_QDR_NET_MAX)) ||
> +				(ADDR_IN_RANGE(addr, QLCNIC_ADDR_DDR_NET,
> +					QLCNIC_ADDR_DDR_NET_MAX)))){

This is improperly indented, function arguments split up into
subsequent lines should line up with the first column after
the openning parenthesis that they are a part of.

On the last line, there needs to be a space between the closing
parenthesis and the openning curly brace.

> +		} else if ((mbx_err_code == QLCNIC_MBX_RSP_OK)
> +				|| (mbx_err_code == QLCNIC_MBX_PORT_RSP_OK)) {

Incorrect indentation, and the "||" should appear at the end of the
first line rather than at the beginning of the second line.

> +			mbx->req.arg[0] = (type | (mbx->req.num << 16) |
> +			(adapter->ahw->fw_hal_version << 29));

This second line needs to be indented properly.  If it makes the line too
long then split the expression up using temporary variables or create
a helper function so you can put the expression at a less deep indentation
level.

> +	cmd.req.arg[1] = cpu_to_le32((mode ? 1 : 0) |
> +		(adapter->recv_ctx->context_id) << 16);

This is not properly indented (and it's extremely tiring explaining
this same thing more than a dozen times during this review)

The first "(" on the second line must line up with the first column
after the openning parenthesis of cpu_to_le32( on the previous
line.

> +		cmd.req.arg[1] = cpu_to_le32(1 |
> +				adapter->recv_ctx->context_id << 16);

Same problem.

> +		cmd.req.arg[1] = cpu_to_le32(2 |
> +				adapter->recv_ctx->context_id << 16);

Same problem.

> +	cmd.req.arg[1] = cpu_to_le32((mode ? (BIT_0 | BIT_1 | BIT_3) : 0) |
> +				     ((adapter->recv_ctx->context_id) << 16));

By some strange miracle you are able to get it correct in this case.

> +	cmd.req.arg[1] = cpu_to_le32(op | (1 << 8) |
> +			(adapter->recv_ctx->context_id << 16));

Again, same problem.

> +	cmd.req.arg[2] = cpu_to_le32(coal->rx_packets |
> +		(coal->rx_time_us << 16));

And here too.

> +		cmd.req.arg[1] = cpu_to_le32(op | BIT_31 |
> +			(func_id << 16));
And again.

> +	for (i = 0, index = 2; i < max_ints; i++, index += 2) {
> +
> +		val = le32_to_cpu(cmd.rsp.arg[index]);

Please remove this unnecessary blank line.

> +	}
> +
> +
> +	th->psh = push;

There is no need for two blank lines here, remove at least one of them.
