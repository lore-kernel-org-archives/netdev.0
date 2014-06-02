From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next v2 1/6] be2net: skip multicast promiscuos
 setting in already set
Date: Mon, 2 Jun 2014 04:44:48 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C56C3651C@CMEXMB1.ad.emulex.com>
References: <1401456988-11395-1-git-send-email-sathya.perla@emulex.com>
 <1401456988-11395-2-git-send-email-sathya.perla@emulex.com>
 <53888CD0.50403@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:39738 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378AbaFBEot convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 00:44:49 -0400
In-Reply-To: <53888CD0.50403@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> 
> Hello.
> 
> On 05/30/2014 05:36 PM, Sathya Perla wrote:
> 
> > From: Kalesh AP <kalesh.purayil@emulex.com>
> 
> > Set mc-promisc (multicast promiscuous) mode on an interface, only if it is
> > *not already* in that mode.
> 
> > Also removed logs that report interface being set to multicast
> > promiscous mode. In an earlier comment on the netdev list such log
> messages
> > were deemed unnecessary as this behaviour is common across most of the
> > ethernet drivers.
> 
> > Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> > Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> 
> [...]
> 
> > diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> > index e1d445d..9116d5e 100644
> > --- a/drivers/net/ethernet/emulex/benet/be_main.c
> > +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> [...]
> > @@ -1244,15 +1242,22 @@ static void be_set_rx_mode(struct net_device
> *netdev)
> >   	}
> >
> >   	status = be_cmd_rx_filter(adapter, IFF_MULTICAST, ON);
> > -
> > -	/* Set to MCAST promisc mode if setting MULTICAST address fails */
> > -	if (status) {
> > -		dev_info(&adapter->pdev->dev,
> > -			 "Exhausted multicast HW filters.\n");
> > -		dev_info(&adapter->pdev->dev,
> > -			 "Disabling HW multicast filtering.\n");
> > -		be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
> > +	if (!status) {
> > +		if (adapter->flags & BE_FLAGS_MCAST_PROMISC)
> > +			adapter->flags &= ~BE_FLAGS_MCAST_PROMISC;
> 
>     Why not just clear it without prior check?
> 

Yes, can be done. But, what is wrong with clearing the flag after the check ?
