From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: 5717 support commit is buggy
Date: Fri, 11 Sep 2009 16:33:52 -0700
Message-ID: <20090911233352.GA12633@xw6200.broadcom.net>
References: <20090911.151554.181296228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1925 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752465AbZIKXd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 19:33:59 -0400
In-Reply-To: <20090911.151554.181296228.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2009 at 03:15:54PM -0700, David Miller wrote:
> Also:
> 
> @@ -13486,7 +13556,8 @@ static void __devinit tg3_init_link_config(struct tg3 *tp)
>  
>  static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
>  {
> -	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
> +	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS &&
> +	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717) {
>  		tp->bufmgr_config.mbuf_read_dma_low_water =
>  			DEFAULT_MB_RDMA_LOW_WATER_5705;
>  		tp->bufmgr_config.mbuf_mac_rx_low_water =
> 
> I wonder what that does with C precedence rules.  Probably need
> parenhesis around "tp->tg3_flags2 & TG3_FLG2_5705_PLUS" for
> safety.

Harbison & Steele says '&' takes precedence over '&&'.  That said, I'm
not shy about adding parens to remove any doubt.

I'm brewing another patchset that contains a patch to address things
like this.  I'll add this to that patch.

