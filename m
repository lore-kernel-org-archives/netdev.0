From: Cacophonix <cacophonix@yahoo.com>
Subject: Re: [PATCH] hp100 -- fixes for new probing.
Date: Wed, 25 Feb 2004 13:33:47 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225213347.5491.qmail@web14006.mail.yahoo.com>
References: <20040224170700.11adc3cc@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040224170700.11adc3cc@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Yes, this fixes the lockup issue (once I renamed addr to ioaddr in hp100_isa_probe1()
to get it to compile. Thanks for the patch!

Next order of business for me is to figure out why the ordering of device recognition
of e100 and hp100 changed between 2.6.0-test* and 2.6.3-mm2 (in the former, hp100 
started up first, while in the latter kernel e100 get's to load up first). I guess I 
could work around this in other ways, but it's a tad disconcerting when eth0, eth1 
and eth2 decide to trade places every so often ;)

Thanks again for the patch.
cheers,
karthik




--- Stephen Hemminger <shemminger@osdl.org> wrote:
> Does fix the problem?  it checks for card before proceeding in hp100_isa_probe
> 
> diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
> --- a/drivers/net/hp100.c	Tue Feb 24 17:05:54 2004
> +++ b/drivers/net/hp100.c	Tue Feb 24 17:05:54 2004
> @@ -333,6 +333,11 @@
>  
>  	if (!request_region(addr, HP100_REGION_SIZE, "hp100"))
>  		goto err;
> +	
> +	if (hp100_inw(HW_ID) != HP100_HW_ID_CASCADE) {
> +		release_region(addr, HP100_REGION_SIZE);
> +		goto err;
> +	}
>  
>  	sig = hp100_read_id(addr);
>  	release_region(addr, HP100_REGION_SIZE);


__________________________________
Do you Yahoo!?
Yahoo! Mail SpamGuard - Read only the mail you want.
http://antispam.yahoo.com/tools
