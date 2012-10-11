From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH] mcs7830: Fix link state detection
Date: Thu, 11 Oct 2012 20:37:04 +0200
Message-ID: <20121011183704.GA8636@rhlx01.hs-esslingen.de>
References: <201210111233.28652.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Mohr <andi@lisas.de>, Greg KH <gregkh@linuxfoundation.org>,
	davem@davemloft.net, Michael Leun <lkml20120218@newton.leun.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201210111233.28652.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Oct 11, 2012 at 12:33:28PM +0200, Ondrej Zary wrote:
>  	u8 *buf = urb->transfer_buffer;
>  	bool link;
> +	struct mcs7830_data *data = mcs7830_get_data(dev);
>  
>  	if (urb->actual_length < 16)
>  		return;

Alternatively could do *data = NULL; and then actually assign after the conditional.
But since the conditional most likely is coldpath
I think your chosen implementation is best.


>  
>  	link = !(buf[1] & 0x20);
>  	if (netif_carrier_ok(dev->net) != link) {

I usually like to introduce helper bools to clearly express the intention
behind things (source code should be readable like a book, yet it all
too often is everything but...).
I.e.
bool link_state_change_detected = (netif_carrier_ok......);
if (bool)

Might be an idea here, too.


The logic behind your counter implementation seems solid to me
(short explanatory comment "track link state several times, to guard against
transient erroneous link state of (some versions of?) this chip"
might have been useful though).

Thank you very much for your patch!

Andreas Mohr
