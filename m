From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: Spurious timeouts in mvmdio
Date: Tue, 17 Dec 2013 14:49:07 +0100
Message-ID: <52B05653.1000004@freebox.fr>
References: <529CA42A.3040504@freebox.fr> <20131203122346.GD29282@titan.lakedaemon.net> <20131203124033.GT16735@n2100.arm.linux.org.uk> <abe249f5cba5c267e2c536bd62c57908@doppler.thel33t.co.uk> <529E5F03.8040607@gmail.com> <8d65780eb7bfe49bb0734a09f05f70a6@doppler.thel33t.co.uk> <529E66A4.4050000@gmail.com> <ae69666fd3b61411d7bbd9ac993cec13@doppler.thel33t.co.uk> <20131203234209.GW16735@n2100.arm.linux.org.uk> <52AF4160.9080703@freebox.fr> <a599b2acdb35fa014ed9480f367fe3a7@doppler.thel33t.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Leigh Brown <leigh@solinno.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a599b2acdb35fa014ed9480f367fe3a7@doppler.thel33t.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/16/2013 07:28 PM, Leigh Brown wrote:

> I prefer this patch (which I think you originally proposed) because it is just as
> correct and the code size is a bit smaller in arm mode, and the same size in
> thumb
> mode (on my compiler gcc 4.7.2, at least).  I coded the loop in that way to
> make it
> small.
>
> I don't mind submitting it to David as I made the mistake in the first place.
>
> Regards,
>
> Leigh.
>
> diff --git a/drivers/net/ethernet/marvell/mvmdio.c
> b/drivers/net/ethernet/marvell/mvmdio.c
> index 7354960..a42a750 100644
> --- a/drivers/net/ethernet/marvell/mvmdio.c
> +++ b/drivers/net/ethernet/marvell/mvmdio.c
> @@ -92,6 +92,12 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
>               if (time_is_before_jiffies(end))
>                   ++timedout;
>               } else {
> +            /* wait_event_timeout does not guarantee a delay of at
> +             * least one whole jiffie, so timeout must be no less
> +             * than two.
> +             */
> +             if (timeout < 2)
> +                 timeout = 2;
>               wait_event_timeout(dev->smi_busy_wait,
>                              orion_mdio_smi_is_done(dev),
>                              timeout);

Hi Leigh,

My original patch changed "timeout" before the entering the while loop, but 
I'm fine with your patch too.

Feel free to add my:

Tested-by: Nicolas Schichan <nschichan@freebox.fr>

Regards,

-- 
Nicolas Schichan
Freebox SAS
