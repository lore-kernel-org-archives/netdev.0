From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 18 Dec 2014 23:14:01 -0800
Message-ID: <20141218231401.3f569ad9@urahara>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34994 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbaLSHOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 02:14:11 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so638070pdi.30
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 23:14:11 -0800 (PST)
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 19:25:19 -0800
Raghu Vatsavayi <rvatsavayi@caviumnetworks.com> wrote:

> +static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
> +{
> +	struct lio *lio;
> +	struct octnet_buf_free_info *finfo;
> +	union octnic_cmd_setup cmdsetup;
> +	struct octnic_data_pkt ndata;
> +	struct octeon_device *oct;
> +	int cpu = 0, status = 0;
> +	int q_idx = 0;
> +	int xmit_more;
> +
> +	lio = GET_LIO(netdev);
> +	oct = lio->oct_dev;
> +	atomic64_inc((atomic64_t *)&lio->stats.tx_packets);
> +	lio->stats.tx_bytes += skb->len;
> +
> +	if (!ifstate_check(lio, LIO_IFSTATE_TXENABLED)) {
> +		lio_info(lio, tx_err, "Transmit Busy, not enabled\n");
> +		return NETDEV_TX_BUSY;
> +	}

This kind of busy handling in transmit, will cause the send in higher
level to retry and spin the CPU. Better to do proper flow control
like other drivers.
