From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH] stmmac: remove custom implementation of print_hex_dump()
Date: Mon, 03 Nov 2014 19:53:57 +0200
Message-ID: <1415037237.472.1.camel@linux.intel.com>
References: <1415035734-24163-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1415035734-24163-2-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1415036355.17743.22.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20365 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246AbaKCRx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 12:53:59 -0500
In-Reply-To: <1415036355.17743.22.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 09:39 -0800, Joe Perches wrote:
> On Mon, 2014-11-03 at 19:28 +0200, Andy Shevchenko wrote:
> > There is a kernel helper to dump buffers in a hexdecimal format. This patch
> > substitutes the open coded function by calling that helper.
> []
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> []
> > @@ -191,14 +191,8 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
> >  
> >  static void print_pkt(unsigned char *buf, int len)
> >  {
> > -	int j;
> > -	pr_debug("len = %d byte, buf addr: 0x%p", len, buf);
> > -	for (j = 0; j < len; j++) {
> > -		if ((j % 16) == 0)
> > -			pr_debug("\n %03x:", j);
> > -		pr_debug(" %02x", buf[j]);
> > -	}
> > -	pr_debug("\n");
> > +	pr_debug("len = %d byte, buf addr: 0x%p\n", len, buf);
> > +	print_hex_dump(KERN_DEBUG, " ", DUMP_PREFIX_OFFSET, 16, 1, buf, len, 0);
> 
> Prefix should be ""

Oh, initially there is an indentation in one space.
Maybe Giuseppe would comment on this.

> Please use true/false for the last argument

Okay.

> 
> Another (better?) option would be to use:
> 
> 	print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, buf, len);

> so that it can be dynamically controlled like
> the pr_debug statements.

Ah, yes, but unfortunately it will print ASCII part always. Giuseppe,
what do you think?

P.S. [off topic] Joe, just would like to know if you have you seen my
last version of the patch series against hexdump.c which adds
seq_hex_dump() call [1]. If so, could you comment on it?
[1] https://lkml.org/lkml/2014/9/4/309

-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
