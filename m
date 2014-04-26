From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Sat, 26 Apr 2014 12:24:00 -0400 (EDT)
Message-ID: <20140426.122400.1793404589768219066.davem@davemloft.net>
References: <20140424204615.GA14757@newterm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: reksio@newterm.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140424204615.GA14757@newterm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Darek Marcinkiewicz <reksio@newterm.pl>
Date: Thu, 24 Apr 2014 22:46:15 +0200

> +struct desc_header {
> +	u32 next:24;
> +	u32 reserved1:7;
> +	u32 next_valid:1;
> +	u32 recv:1;
> +	u32 reserved2:31;
> +	u16 len:12;
> +	u16 reserved3:4;
> +	u16 port;
> +	u32 reserved4;
> +	u64 timestamp;
> +};
> +
> +struct rx_desc {
> +	struct desc_header header;
> +#define RX_PAYLOAD_SIZE		0x7e8
> +	u8 data[RX_PAYLOAD_SIZE];
> +};
> +
> +struct tx_header {
> +	u16 length;
> +	u8 port0:1;
> +	u8 port1:1;
> +	u8 reserved1:6;
> +	u8 ts_enable:1;
> +	u8 reserved2:7;
> +	u32 sent:1;
> +	u32 reserved3:31;
> +	u64 timestamp;
> +};

All of these descriptor structures need to be properly annotated using
endianness types, and their fields accessed using proper endian
translating interfaces such as le32_to_cpu() et al.
