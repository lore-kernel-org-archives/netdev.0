From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [net-next PATCH] net: dcb: add CEE notify calls
Date: Mon, 23 Apr 2012 15:51:52 +0300
Message-ID: <1335185512.15423.10.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <20120420194923.8103.54825.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	amirv@dev.mellanox.co.il
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2868 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754225Ab2DWKtY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2012 06:49:24 -0400
In-Reply-To: <20120420194923.8103.54825.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  net/dcb/dcbnl.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
> index 8dfa1da..656c7c7 100644
> --- a/net/dcb/dcbnl.c
> +++ b/net/dcb/dcbnl.c
> @@ -704,6 +704,7 @@ static int dcbnl_setapp(struct net_device *netdev, struct nlattr **tb,
>  
>  	ret = dcbnl_reply(err, RTM_SETDCB, DCB_CMD_SAPP, DCB_ATTR_APP,
>  			  pid, seq, flags);
> +	dcbnl_cee_notify(netdev, RTM_SETDCB, DCB_CMD_SAPP, seq, 0);
>  out:
>  	return ret;
>  }
> @@ -936,6 +937,7 @@ static int dcbnl_setall(struct net_device *netdev, struct nlattr **tb,
>  
>  	ret = dcbnl_reply(netdev->dcbnl_ops->setall(netdev), RTM_SETDCB,
>  	                  DCB_CMD_SET_ALL, DCB_ATTR_SET_ALL, pid, seq, flags);
> +	dcbnl_cee_notify(netdev, RTM_SETDCB, DCB_CMD_SET_ALL, seq, 0);
>  
>  	return ret;
>  }
> 

In case of a FW DCBx agent these notification could be a bit confusing.
In this case, the dcbnl_setxxx operations are used to set the initial
negotiation parameters. dcbnl_setall triggers the negotiation and some
time after that the FW DCBx agent driver should send a notification with
the newly negotiated values. The notifications sent form within the set
operations will return the current negotiated values which may very soon
change. If we want to keep the user mode code simple and unified maybe
we should send these notifications only if the DCBx agent is host based.

Shmulik 
