From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 3/3] net: netcp: rework the code for get/set sw_data in dma desc
Date: Fri, 19 Feb 2016 21:55:14 +0100
Message-ID: <3256728.DYdlef6xAF@wuerfel>
References: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com> <1455904724-17952-4-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455904724-17952-4-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 February 2016 12:58:44 Murali Karicheri wrote:
> SW data field in descriptor can be used by software to hold private
> data for the driver. As there are 4 words available for this purpose,
> use separate macros to place it or retrieve the same to/from
> descriptors. Also do type cast of data types accordingly.
> 
> Cc: Wingman Kwok <w-kwok2@ti.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> CC: Arnd Bergmann <arnd@arndb.de>
> CC: Grygorii Strashko <grygorii.strashko@ti.com>
> CC: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>

Looks ok in principle.

Acked-by: Arnd Bergmann <arnd@arndb.de>

>  		get_pkt_info(&dma_buf, &tmp, &dma_desc, ndesc);
> -		get_sw_data((u32 *)&buf_ptr, &buf_len, ndesc);
> +		/* warning!!!! We are retrieving the virtual ptr in the sw_data
> +		 * field as a 32bit value. Will not work on 64bit machines
> +		 */
> +		buf_ptr = (void *)GET_SW_DATA0(ndesc);
> +		buf_len = (int)GET_SW_DATA1(desc);

I would have abstracted the retrieval of a pointer again,
and added the comment in the helper function once, it doesn't
really need to be duplicated everywhere.

	Arnd
