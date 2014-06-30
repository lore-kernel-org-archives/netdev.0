From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next 4/4] be2net: re-enable vlan filtering mode asap
Date: Mon, 30 Jun 2014 07:13:34 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C56C8E3EE@CMEXMB1.ad.emulex.com>
References: <1403869401-6545-1-git-send-email-sathya.perla@emulex.com>
 <1403869401-6545-5-git-send-email-sathya.perla@emulex.com>
 <53AD6E40.2050407@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:13501 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaF3HNg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 03:13:36 -0400
In-Reply-To: <53AD6E40.2050407@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> 
> Hello.
> 
> On 06/27/2014 03:43 PM, Sathya Perla wrote:
> 
> > From: Kalesh AP <kalesh.purayil@emulex.com>
> 
> > While adding vlans, when the HW limit of vlan filters is reached, the
> > driver enables vlan promiscuous mode.
> > Similarily, while removing vlans, the driver must re-enable HW filtering
> > as soon as the number of vlan filters is within the HW limit.
> 
> > Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> > Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> > ---
> >   drivers/net/ethernet/emulex/benet/be_main.c |    9 +++------
> >   1 files changed, 3 insertions(+), 6 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> > index 5ac9d13..3cf490b 100644
> > --- a/drivers/net/ethernet/emulex/benet/be_main.c
> > +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> > @@ -1176,15 +1176,12 @@ static int be_vlan_rem_vid(struct net_device
> *netdev, __be16 proto, u16 vid)
> >
> >   	/* Packets with VID 0 are always received by Lancer by default */
> >   	if (lancer_chip(adapter) && vid == 0)
> > -		goto ret;
> > +		return status;
> >
> >   	clear_bit(vid, adapter->vids);
> > +	adapter->vlans_added--;
> > +
> >   	status = be_vid_config(adapter);
> > -	if (!status)
> > -		adapter->vlans_added--;
> > -	else
> > -		set_bit(vid, adapter->vids);
> > -ret:
> >   	return status;
> 
>     You now can merge the above lines into:
> 
> 	return be_vid_config(adapter);

Sure, will do.
