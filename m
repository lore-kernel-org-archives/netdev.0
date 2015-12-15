From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch v2] qlcnic: fix a timeout loop
Date: Tue, 15 Dec 2015 23:17:34 +0300
Message-ID: <20151215201734.GJ5177@mwanda>
References: <BLUPR11MB0114ED16EBE57CC01FD9797393EE0@BLUPR11MB0114.namprd11.prod.outlook.com>
 <20151215135616.GA18851@mwanda>
 <20151215.131341.175421419282676757.davem@davemloft.net>
 <20151215201350.GI5177@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dept-GELinuxNICDev@qlogic.com, manish.chopra@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	rajesh.borundia@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46891 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbbLOURq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 15:17:46 -0500
Content-Disposition: inline
In-Reply-To: <20151215201350.GI5177@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2015 at 11:13:50PM +0300, Dan Carpenter wrote:
> On Tue, Dec 15, 2015 at 01:13:41PM -0500, David Miller wrote:
> > From: Dan Carpenter <dan.carpenter@oracle.com>
> > Date: Tue, 15 Dec 2015 16:56:16 +0300
> > 
> > > The problem here is that at the end of the loop we test for if
> > > idc->vnic_wait_limit is zero, but since idc->vnic_wait_limit-- is a
> > > post-op, it actually ends up set to (u8)-1.  I have fixed this by
> > > moving the decrement inside the loop.
> > > 
> > > Fixes: 486a5bc77a4a ('qlcnic: Add support for 83xx suspend and resume.')
> > > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > Applied.
> 
> Ugh...  I appologize, I just noticed a mistake in this one.  I have to
> do the decrement at the end of the loop and not the start of the loop.
> 

Nope.  I'm wrong again.  My original patch was the correct way to do
this.  Otherwise you can end up with state == QLCNIC_DEV_NPAR_OPER and
->vnic_wait_limit set to zero.

regards,
dan carpenter
