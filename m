From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [net-next] cxgb4: Enhance driver to update FW, when FW is too old
Date: Thu, 8 Oct 2015 09:02:25 +0530
Message-ID: <20151008033220.GA15259@hariprasad-pc.asicdesigners.com>
References: <1444189900-5940-1-git-send-email-hariprasad@chelsio.com>
 <20151007190956.GA26590@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	nirranjan@chelsio.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:16631 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750908AbbJHDcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 23:32:43 -0400
Content-Disposition: inline
In-Reply-To: <20151007190956.GA26590@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 07, 2015 at 15:09:57 -0400, Neil Horman wrote:
> On Wed, Oct 07, 2015 at 09:21:40AM +0530, Hariprasad Shenai wrote:
> > t4_check_fw_version() can return several error codes (-EINVAL, -EBUSY,
> > -EAGAIN). The present code sets the adapter state to UNINIT only if its
> > an EFAULT. In all the error cases set the adapter to uninitialized state.
> > 
> > In t4_check_fw_version() if call to t4_read_flash() fails, repeat the
> > operation a few times before returning failure.
> > 
> > Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> > ---
> >  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 +-
> >  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 6 +++++-
> >  2 files changed, 6 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > index 9f1f5b2..c29227e 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > +		ret = t4_get_fw_version(adap, &adap->params.fw_vers);
> > +
> Shouldn't you only retry if you get an error that indicates the error is
> transient (i.e. EBUSY or EAGAIN)?
> Neil
> 
Yes you are right. Will send a V2 for the same.

Thanks
Hari

> 
> >  	if (ret)
> >  		return ret;
> >  
