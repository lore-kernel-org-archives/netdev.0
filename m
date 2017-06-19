From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] s390/diag: add diag26c support
Date: Mon, 19 Jun 2017 10:47:26 -0400 (EDT)
Message-ID: <20170619.104726.1778743929564587843.davem@davemloft.net>
References: <20170619112225.30471-1-jwi@linux.vnet.ibm.com>
        <20170619112225.30471-4-jwi@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: jwi@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58534 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdFSOr2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 10:47:28 -0400
In-Reply-To: <20170619112225.30471-4-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Date: Mon, 19 Jun 2017 13:22:24 +0200

> +#define DIAG26C_GET_MAC	0x0000
> +struct diag26c_mac_req {
> +	u32	resp_buf_len;
> +	u32	resp_version;
> +	u16	op_code;
> +	u16	devno;
> +	u8	res[4];
> +} __packed;

The packed attribute is not necessary here, the structure will be
perfectly packed together because of the types used and the order of
the members.

__packed is to be used only in the last possible resort for
correctness and every effort whatsoever should be used to avoid using
it.

> +
> +struct diag26c_mac_resp {
> +	u32	version;
> +	u8	mac[ETH_ALEN];
> +	u16	res;
> +} __packed __aligned(8);

Using packed with an 8 byte alignment is even more unnecessary.

Again, it is not needed, so please don't use it.

> + */
> +static inline int __diag26c(void *req, void *resp, enum diag26c_sc subcode)

Do not mark functions inline in *.c files, let the compiler decide.
