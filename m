From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next] macvlan: propagate the mac address change status for lowerdev
Date: Wed, 14 Jun 2017 23:26:14 +0800
Message-ID: <000801d2e522$9019e2b0$b04da810$@cmss.chinamobile.com>
References: <1497365111-34821-1-git-send-email-zhangshengju@cmss.chinamobile.com> <20170613203408.GA3112@yuvallap>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <fgao@48lvckh6395k16k5.yundunddos.com>,
        <vyasevic@redhat.com>, <netdev@vger.kernel.org>
To: "'Yuval Shaia'" <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:54587 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752493AbdFNP0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 11:26:19 -0400
In-Reply-To: <20170613203408.GA3112@yuvallap>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Yuval Shaia [mailto:yuval.shaia@oracle.com]
> Sent: Wednesday, June 14, 2017 4:34 AM
> To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Cc: davem@davemloft.net; fgao@48lvckh6395k16k5.yundunddos.com;
> vyasevic@redhat.com; netdev@vger.kernel.org
> Subject: Re: [net-next] macvlan: propagate the mac address change status
> for lowerdev
> 
> On Tue, Jun 13, 2017 at 10:45:11PM +0800, Zhang Shengju wrote:
> > The macvlan dev should propagate the return value of mac address
> > change for lower device in the passthru mode, instead of always return
0.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> > ---
> >  drivers/net/macvlan.c | 6 ++----
> >  1 file changed, 2 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c index
> > 346ad2f..ade1213 100644
> > --- a/drivers/net/macvlan.c
> > +++ b/drivers/net/macvlan.c
> > @@ -703,10 +703,8 @@ static int macvlan_set_mac_address(struct
> net_device *dev, void *p)
> >  	if (!is_valid_ether_addr(addr->sa_data))
> >  		return -EADDRNOTAVAIL;
> >
> > -	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
> > -		dev_set_mac_address(vlan->lowerdev, addr);
> > -		return 0;
> > -	}
> > +	if (vlan->mode == MACVLAN_MODE_PASSTHRU)
> > +		return dev_set_mac_address(vlan->lowerdev, addr);
> 
> Do you think the following functions needs this fix as well?
> - alb_set_mac_address
> - bond_alb_handle_active_change
> - bond_enslave
> - __bond_release_one
> - macvlan_set_mac_address
> 
> Yuval
Actually, this patch fixes macvlan part. 
The other part is not so easy to fix in my option, you can try to fix if
possible.

BRs,
ZSJ
> 
> >
> >  	return macvlan_sync_address(dev, addr->sa_data);  }
> > --
> > 1.8.3.1
> >
> >
> >
