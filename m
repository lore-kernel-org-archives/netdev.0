From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v2 4/4] net-next: stmmac: rework the speed selection
Date: Tue, 23 May 2017 09:10:15 +0200
Message-ID: <20170523071015.GA9279@Red>
References: <20170522123347.5295-1-clabbe.montjoie@gmail.com>
 <20170522123347.5295-5-clabbe.montjoie@gmail.com>
 <20170522.144944.1978795354564077830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35515 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751318AbdEWHKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 03:10:25 -0400
Content-Disposition: inline
In-Reply-To: <20170522.144944.1978795354564077830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 02:49:44PM -0400, David Miller wrote:
> From: Corentin Labbe <clabbe.montjoie@gmail.com>
> Date: Mon, 22 May 2017 14:33:47 +0200
> 
> > -	mac->link.port = GMAC_CONTROL_PS;
> >  	mac->link.duplex = GMAC_CONTROL_DM;
> > -	mac->link.speed = GMAC_CONTROL_FES;
> > +	mac->link.speed10 = GMAC_CONTROL_PS;
> > +	mac->link.speed100 = GMAC_CONTROL_PS | GMAC_CONTROL_FES;
> > +	mac->link.speed1000 = 0;
> > +	mac->link.speed_mask = GENMASK(15, 14);
> 
> Neither GMAC_CONTROL_PS nor GMAC_CONTROL_FES are defined with
> the GENMASK() macro.  So it is very confusing to see constant
> bit specifications here in C code.
> 
> There are two ways to do this properly:
> 
> 1) Use "(GMAC_CONTROL_PS | GMAC_CONTROL_FES)"
> 
> 2) Define a new GMAC_CONTROL_SPDMASK to "GMAC_CONTROL_PS | GMAC_CONTROL_FES"
>    and use that here.
> 

Since dwmac100 use the #1, I will do the same on dwmac4/dwmac1000

Thanks.
