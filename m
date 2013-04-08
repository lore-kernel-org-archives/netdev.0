From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Mon, 8 Apr 2013 08:40:10 +0200
Message-ID: <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
 <1365175702.3405.2.camel@edumazet-glaptop>
 <1365175872.3405.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:49712 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933282Ab3DHGpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 02:45:13 -0400
Content-Disposition: inline
In-Reply-To: <1365175872.3405.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 05, 2013 at 08:31:12AM -0700, Eric Dumazet wrote:
> On Fri, 2013-04-05 at 08:28 -0700, Eric Dumazet wrote:
> 
> >  /* Process the RX completion indicated by rxcp when GRO is disabled */
> > -static void be_rx_compl_process(struct be_rx_obj *rxo,
> > +static void be_rx_compl_process(struct be_rx_obj *rxo, struct napi_struct *napi,
> >  				struct be_rx_compl_info *rxcp)
> >  {
> >  	struct be_adapter *adapter = rxo->adapter;
> > @@ -1385,7 +1385,7 @@ static void be_rx_compl_process(struct be_rx_obj *rxo,
> >  	if (rxcp->vlanf)
> >  		__vlan_hwaccel_put_tag(skb, rxcp->vlan_tag);
> >  
> > -	netif_receive_skb(skb);
> > +	napi_gro_receive(&napi, skb);
> 
> That would be : napi_gro_receive(napi, skb);
> 

Thanks Eric, it works as expected after applying this.

//E
