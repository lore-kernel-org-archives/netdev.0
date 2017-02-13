From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch net-next] net: qcom/emac: fix a sizeof() typo
Date: Mon, 13 Feb 2017 17:00:40 +0300
Message-ID: <20170213140040.GB4108@mwanda>
References: <20170213110021.GA17205@mwanda>
 <58A19E97.6000704@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20944 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdBMOBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:01:02 -0500
Content-Disposition: inline
In-Reply-To: <58A19E97.6000704@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 12:55:03PM +0100, walter harms wrote:
> 
> 
> Am 13.02.2017 12:00, schrieb Dan Carpenter:
> > We had intended to say "sizeof(u32)" but the "u" is missing.
> > Fortunately, sizeof(32) is also 4, so the original code still works.
> > 
> > Fixes: c4e7beea2192 ("net: qcom/emac: add ethtool support for reading hardware registers")
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
> > index 0d9945fb79be..bbe24639aa5a 100644
> > --- a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
> > +++ b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
> > @@ -227,7 +227,7 @@ static void emac_get_regs(struct net_device *netdev,
> >  
> >  static int emac_get_regs_len(struct net_device *netdev)
> >  {
> > -	return EMAC_MAX_REG_SIZE * sizeof(32);
> > +	return EMAC_MAX_REG_SIZE * sizeof(u32);
> >  }
> >  
> 
> 
> We have a function where the argument is ignored and the rest is const ?
> 
> emac_ethtool_get_regs_len seems the only user. So it would be fairly easy to
> move that into that function.

It's not the only user.  We have to pass netdev because it's used as a
function pointer.

regards,
dan carpenter
