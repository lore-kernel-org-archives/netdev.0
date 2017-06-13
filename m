From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_iucv: Move sockaddr length checks to before
 accessing sa_family in bind and connect handlers
Date: Tue, 13 Jun 2017 16:15:42 -0400 (EDT)
Message-ID: <20170613.161542.837461878998748762.davem@davemloft.net>
References: <20170613174228.9218-1-mjurczyk@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jwi@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com,
        linux-s390@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: mjurczyk@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613174228.9218-1-mjurczyk@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mateusz Jurczyk <mjurczyk@google.com>
Date: Tue, 13 Jun 2017 19:42:28 +0200

> Verify that the caller-provided sockaddr structure is large enough to
> contain the sa_family field, before accessing it in bind() and connect()
> handlers of the AF_IUCV socket. Since neither syscall enforces a minimum
> size of the corresponding memory region, very short sockaddrs (zero or
> one byte long) result in operating on uninitialized memory while
> referencing .sa_family.
> 
> Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
...
>  	/* Verify the input sockaddr */
> -	if (!addr || addr->sa_family != AF_IUCV)
> -		return -EINVAL;
> -
> -	if (addr_len < sizeof(struct sockaddr_iucv))
> +	if (!addr || addr_len < sizeof(struct sockaddr_iucv) ||
> +	    addr->sa_family != AF_IUCV)

The 'addr' can never be NULL so please remove that check, thank you.
