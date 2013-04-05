From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Fri, 05 Apr 2013 08:31:12 -0700
Message-ID: <1365175872.3405.3.camel@edumazet-glaptop>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
	 <1365175702.3405.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35281 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243Ab3DEPbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 11:31:21 -0400
Received: by mail-pa0-f44.google.com with SMTP id bi5so2111219pad.17
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 08:31:21 -0700 (PDT)
In-Reply-To: <1365175702.3405.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-05 at 08:28 -0700, Eric Dumazet wrote:

>  /* Process the RX completion indicated by rxcp when GRO is disabled */
> -static void be_rx_compl_process(struct be_rx_obj *rxo,
> +static void be_rx_compl_process(struct be_rx_obj *rxo, struct napi_struct *napi,
>  				struct be_rx_compl_info *rxcp)
>  {
>  	struct be_adapter *adapter = rxo->adapter;
> @@ -1385,7 +1385,7 @@ static void be_rx_compl_process(struct be_rx_obj *rxo,
>  	if (rxcp->vlanf)
>  		__vlan_hwaccel_put_tag(skb, rxcp->vlan_tag);
>  
> -	netif_receive_skb(skb);
> +	napi_gro_receive(&napi, skb);

That would be : napi_gro_receive(napi, skb);
