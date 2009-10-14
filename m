From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] net/hamradio: fix test in receive()
Date: Tue, 13 Oct 2009 19:10:03 -0700
Message-ID: <20091013191003.9778c4bb.akpm@linux-foundation.org>
References: <4ACB27E8.8060401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Thomas Sailer <t.sailer@alumni.ethz.ch>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44094 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760617AbZJNCK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 22:10:56 -0400
In-Reply-To: <4ACB27E8.8060401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Oct 2009 13:20:08 +0200 Roel Kluin <roel.kluin@gmail.com> wrote:

> The negation makes it a bool before the comparison and hence it
> will never evaluate to true.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Was this intended?
> 
> diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
> index 7bcaf7c..ee06a13 100644
> --- a/drivers/net/hamradio/baycom_epp.c
> +++ b/drivers/net/hamradio/baycom_epp.c
> @@ -596,7 +596,8 @@ static int receive(struct net_device *dev, int cnt)
>  						state = 0;
>  
>  					/* not flag received */
> -					else if (!(bitstream & (0x1fe << j)) != (0x0fc << j)) {
> +					else if ((bitstream & (0x1fe << j)) !=
> +							(0x0fc << j)) {
>  						if (state)
>  							do_rxpacket(dev);
>  						bc->hdlcrx.bufcnt = 0;

It does look like that is what was intended.

With this fix we're turning on a code path which probably hasn't been
executed by anyone in a decade or so.  I wonder what it'll do?

