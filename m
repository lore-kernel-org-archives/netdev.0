From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] X25: Add ITU-T facilites
Date: Tue, 18 Oct 2005 15:23:18 +0900 (JST)
Message-ID: <20051018.152318.68554424.yoshfuji@linux-ipv6.org>
References: <1129513666.3747.50.camel@localhost.localdomain>
	<20051017022826.GA23167@mandriva.com>
	<1129615767.3695.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, eis@baty.hanse.de,
	linux-x25@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932414AbVJRGXa@vger.kernel.org>
To: ahendry@tusc.com.au
In-Reply-To: <1129615767.3695.15.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1129615767.3695.15.camel@localhost.localdomain> (at Tue, 18 Oct 2005 16:09:27 +1000), Andrew Hendry <ahendry@tusc.com.au> says:

> +/* 
> +*     ITU DTE facilities
> +*     Only the called and calling address
> +*     extension are currently implemented.
> +*     The rest are in place to avoid the struct
> +*     changing size if someone needs them later
> ++ */
> +struct x25_dte_facilities {
> +	unsigned int    calling_len, called_len;
> +	char            calling_ae[20];
> +	char            called_ae[20];
> +	unsigned char   min_throughput;
> +	unsigned short  delay_cumul;
> +	unsigned short  delay_target;
> +	unsigned short  delay_max;
> +	unsigned char   expedited;
> +};

Why don't you use fixed size members?
And we can eliminate 8bit hole.

struct x25_dte_facilities {
     u32             calling_len
     u32             called_len;
     u8              calling_ae[20];
     u8              called_ae[20];
     u8              min_throughput;
     u8              expedited;
     u16             delay_cumul;
     u16             delay_target;
     u16             delay_max;
};

--yoshfuji
