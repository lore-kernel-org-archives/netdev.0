From: Simon Horman <horms@verge.net.au>
Subject: Re: can-bcm: fix minor heap overflow
Date: Fri, 12 Nov 2010 11:39:50 +0900
Message-ID: <20101112023950.GA8145@verge.net.au>
References: <4CDB1856.4040001@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Dan Rosenberg <drosenberg@vsecurity.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Urs Thuermann <urs@isnogud.escape.de>, security@kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48159 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064Ab0KLCjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 21:39:55 -0500
Content-Disposition: inline
In-Reply-To: <4CDB1856.4040001@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 10, 2010 at 11:10:30PM +0100, Oliver Hartkopp wrote:
> On 64-bit platforms the ASCII representation of a pointer may be up to 17
> bytes long. This patch increases the length of the buffer accordingly.
> 
> http://marc.info/?l=linux-netdev&m=128872251418192&w=2
> 
> Reported-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> CC: Linus Torvalds <torvalds@linux-foundation.org>
> 
> ---
> 
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 08ffe9e..6faa825 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -125,7 +125,7 @@ struct bcm_sock {
>  	struct list_head tx_ops;
>  	unsigned long dropped_usr_msgs;
>  	struct proc_dir_entry *bcm_proc_read;
> -	char procname [9]; /* pointer printed in ASCII with \0 */
> +	char procname [20]; /* pointer printed in ASCII with \0 */
>  };

If the string may be up to 17 bytes long why are you allocating 20?

>  static inline struct bcm_sock *bcm_sk(const struct sock *sk)
