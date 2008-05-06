From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] [NET] uli526x: initialize the hardware prior to requesting
 interrupts
Date: Tue, 06 May 2008 12:18:38 -0400
Message-ID: <482084DE.9030309@pobox.com>
References: <20080429155313.GA28166@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45312 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbYEFQSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:18:43 -0400
In-Reply-To: <20080429155313.GA28166@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> The firmware on MPC8610HPCD boards enables ULI ethernet and leaves it
> in some funky state before booting Linux. For drivers, it's always good
> idea to (re)initialize the hardware prior to requesting interrupts.
> 
> This patch fixes the following oops:
> 
> Oops: Kernel access of bad area, sig: 11 [#1]
> MPC86xx HPCD
> NIP: c0172820 LR: c017287c CTR: 00000000
> [...]
> NIP [c0172820] allocate_rx_buffer+0x2c/0xb0
> LR [c017287c] allocate_rx_buffer+0x88/0xb0
> Call Trace:
> [df82bdc0] [c017287c] allocate_rx_buffer+0x88/0xb0 (unreliable)
> [df82bde0] [c0173000] uli526x_interrupt+0xe4/0x49c
> [df82be20] [c0045418] request_irq+0xf0/0x114
> [df82be50] [c01737b0] uli526x_open+0x48/0x160
> [df82be70] [c0201184] dev_open+0xb0/0xe8
> [df82be80] [c0200104] dev_change_flags+0x90/0x1bc
> [df82bea0] [c035fab0] ip_auto_config+0x214/0xef4
> [df82bf60] [c03421c8] kernel_init+0xc4/0x2ac
> [df82bff0] [c0010834] kernel_thread+0x44/0x60
> Instruction dump:
> 4e800020 9421ffe0 7c0802a6 bfa10014 7c7e1b78 90010024 80030060 83e30054
> 2b80002f 419d0078 3fa0c039 48000058 <907f0010> 80630088 2f830000 419e0014
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
>  drivers/net/tulip/uli526x.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)

applied 1-2


