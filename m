From: Thomas Graf <tgraf@suug.ch>
Subject: Re: primary and secondary ip addresses
Date: Thu, 26 May 2005 20:21:46 +0200
Message-ID: <20050526182146.GV15391@postel.suug.ch>
References: <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com> <1103550901.1050.292.camel@jzny.localdomain> <20050412105442.GV7510@sunbeam.de.gnumonks.org> <200505081531.16106.hasso@estpak.ee> <20050526181118.GK13114@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Hasso Tepper <hasso@estpak.ee>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20050526181118.GK13114@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Harald Welte <20050526181118.GK13114@sunbeam.de.gnumonks.org> 2005-05-26 20:11
> David, would you consider applying that patch to mainline?  I think
> there was concensus on this solution, and it has now received some
> amount of testing by Hasso and me.

I agree, I've been running this patch for 3 weeks now without
any problems. Two comments below.

> @@ -281,6 +289,13 @@
>  		if (!in_dev->ifa_list)
>  			inetdev_destroy(in_dev);
>  	}
> +
> +	if (promote && IN_DEV_PROMOTE_SECONDARIES(in_dev)) {

promote can only be !=NULL if promotion is enabled, no?

> +		/* not sure if we should send a delete notify first? */
> +		promote->ifa_flags &= ~IFA_F_SECONDARY;
> +		rtmsg_ifa(RTM_NEWADDR, promote);

This can be improved, however sending a delete/add seems
inappropriate. I've patch prepared to add a change mask
which will give us the proper methods to do this right
but for now this is just fine I guess.
