From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] Net driver bugs fix
Date: Tue, 10 May 2016 14:40:25 -0400 (EDT)
Message-ID: <20160510.144025.1073437249454620246.davem@davemloft.net>
References: <1462814000-16331-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: noamca@mellanox.com, linux-kernel@vger.kernel.org,
	abrodkin@synopsys.com, netdev@vger.kernel.org
To: eladkan@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462814000-16331-1-git-send-email-eladkan@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elad Kanfi <eladkan@mellanox.com>
Date: Mon, 9 May 2016 20:13:18 +0300

> Summary:
>  1. Bug description: TX done interrupts that arrives while interrupts
>     are masked, during NAPI poll, will not trigger an interrupt handling.
>     Since TX interrupt is of level edge we will lose the TX done interrupt.
>     As a result all pending tx frames will get no service.
> 
>     Solution: Check if there is a pending tx request after unmasking the
>     interrupt and if answer is yes then re-add ourselves to
>     the NAPI poll list.
> 
>  2. Bug description: CPU-A before sending a frame will set a variable
>     to true. CPU-B that executes the tx done interrupt service routine
>     might read a non valid value of that variable.
> 
>     Solution: Use the socket buffer pointer instead of the variable,
>     and add a write memory barrier at the tx sending function after
>     the pointer is set.

Series applied, thanks.
