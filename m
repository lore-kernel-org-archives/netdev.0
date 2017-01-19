From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [Xen-devel] xennet_start_xmit assumptions
Date: Thu, 19 Jan 2017 06:14:26 -0500
Message-ID: <20170119111426.GA22018@oracle.com>
References: <20170118153132.GB9258@oracle.com>
 <20170118192528.GA6847@char.us.oracle.com>
 <de0d7a7db4c24b46838aee7623d5d2a3@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Wei Liu <wei.liu2@citrix.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29387 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751596AbdASLQI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 06:16:08 -0500
Content-Disposition: inline
In-Reply-To: <de0d7a7db4c24b46838aee7623d5d2a3@AMSPEX02CL03.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/19/17 09:36), Paul Durrant wrote:
> 
> Hi Sowmini,
> 
>   Sounds like a straightforward bug to me... netfront should be able
> to handle an empty skb and clearly, if it's relying on skb_headlen()
> being non-zero, that's not the case.
> 
>   Paul

I see. Seems like there are 2 things broken here: recovering
from skb->len = 0, and recovering from  the more complex
case of (skb->len > 0 && skb_headlen(skb) == 0)

Do you folks want to take a shot at fixing this,
since you know the code better? If you are interested,
I can share my test program to help you reproduce the 
simpler skb->len == 0 case, but it's the fully non-linear
skbs that may be more interesting to reproduce/fix. 

I'll probably work on fixing packet_snd to return -EINVAL 
or similar when the len is zero this week.

--Sowmini
