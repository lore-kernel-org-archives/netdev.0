From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking
 drivers
Date: Sat, 27 Feb 2010 01:53:50 -0800 (PST)
Message-ID: <20100227.015350.71138134.davem@davemloft.net>
References: <51f3faa71002260646r705891e8tdbab1f6faeeb4b81@mail.gmail.com>
	<201002261625.24523.bzolnier@gmail.com>
	<51f3faa71002261908y7cfa62eeicb3e56d5c920887a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bzolnier@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: hancockrwd@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51f3faa71002261908y7cfa62eeicb3e56d5c920887a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Hancock <hancockrwd@gmail.com>
Date: Fri, 26 Feb 2010 21:08:04 -0600

> That seems like a reasonable approach to me. Only question is how to
> implement the check for DMA_64BIT. Can we just check page_to_phys on
> each of the pages in the skb to see if it's > 0xffffffff ? Are there
> any architectures where it's more complicated than that?

On almost every platform it's "more complicated than that".

This is the whole issue.  What matters is the final DMA address and
since we have IOMMUs and the like, it is absolutely not tenable to
solve this by checking physical address attributes.
