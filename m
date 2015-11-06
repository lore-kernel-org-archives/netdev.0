From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH net 4/5] bnxt_en: Fix comparison of u16 sw_id against
 negative value.
Date: Fri, 6 Nov 2015 09:55:08 -0800
Message-ID: <1446832508.5220.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
	 <1446758751-27999-5-git-send-email-mchan@broadcom.com>
	 <563C95C2.6060606@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:4531 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161803AbbKFRzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 12:55:11 -0500
In-Reply-To: <563C95C2.6060606@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-11-06 at 14:57 +0300, Sergei Shtylyov wrote: 
> Hello.
> 
> On 11/6/2015 12:25 AM, Michael Chan wrote:
> 
> > Assign the return value from bitmap_find_free_region() to an integer
> > variable and check for negative error codes first, before assigning
> > the bit ID to the unsigned sw_id field.
> >
> > Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > ---
> >   drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 +++++----
> >   1 file changed, 5 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> > index a62deff..db15c5e 100644
> > --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> > +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> > @@ -5307,7 +5307,7 @@ static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
> >   	struct bnxt_ntuple_filter *fltr, *new_fltr;
> >   	struct flow_keys *fkeys;
> >   	struct ethhdr *eth = (struct ethhdr *)skb_mac_header(skb);
> > -	int rc = 0, idx;
> > +	int rc = 0, idx, bit_id;
> 
>     I'd use the already declared 'rc' variable.
> 

I agree with you.  Normally, rc should only contain 0 or negative error
codes and is returned to the caller.  In this particular case, the
caller expects negative or non negative values and we could have used
rc.

Perhaps I'll make the change in the next round of patches.  Thanks.
