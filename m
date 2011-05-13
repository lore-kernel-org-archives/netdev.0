From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: FLOW_EXT may confuse drivers
Date: Fri, 13 May 2011 16:01:38 +0100
Message-ID: <1305298898.2851.7.camel@bwh-desktop>
References: <OFDA6F039C.B25E3B43-ON8525788F.004EA678-8525788F.004EA67B@BeldenCDT.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Sebastian.Poehn@Belden.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59365 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759070Ab1EMPBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 11:01:41 -0400
In-Reply-To: <OFDA6F039C.B25E3B43-ON8525788F.004EA678-8525788F.004EA67B@BeldenCDT.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please send ethtool patches directly to me as well as to netdev.

On Fri, 2011-05-13 at 10:19 -0400, Sebastian.Poehn@Belden.com wrote:
> The FLOW_EXT bit must be masked out. Otherwise if e.g. vlan is set a
> driver receiving the ntuple may not detect the flow_type correctly!
> 
> Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
> 
> diff --git a/ethtool.c b/ethtool.c
> index 34fe107..0b7ec05 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -3134,6 +3134,9 @@ static int flow_spec_to_ntuple(struct ethtool_rx_flow_spec *fsp,
>                  (u64)ntohl(~fsp->m_ext.data[1]);
>          }
>      }
> +    
> +    /*Mask out the extended bit, because ntuple does not know it!*/
> +    ntuple->flow_type &= ~FLOW_EXT;
>  
>      return 0;
>  }
> 
> DISCLAIMER:
> 
> Privileged and/or Confidential information may be contained in this
> message. If you are not the addressee of this message, you may not
> copy, use or deliver this message to anyone. In such event, you
> should destroy the message and kindly notify the sender by reply
> e-mail. It is understood that opinions or conclusions that do not
> relate to the official business of the company are neither given
> nor endorsed by the company.

I am not the addressee, so I won't apply this (even though it looks
right).  Please get rid of this disclaimer on messages to public mailing
lists.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

