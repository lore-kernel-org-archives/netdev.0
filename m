From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH] RDMA/cxgb3: logical-/bit-or confusion?
Date: Wed, 18 Feb 2009 18:53:40 -0600
Message-ID: <499CAD94.8000108@opengridcomputing.com>
References: <499BD470.4080705@gmail.com> <499C0143.1080703@gmail.com> <adazlgjz2g0.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roel Kluin <roel.kluin@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:37780 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751934AbZBSAxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 19:53:43 -0500
In-Reply-To: <adazlgjz2g0.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
>  > -	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) | crc_enabled ? 1 : 0;
>  > +	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) || crc_enabled ? 1 : 0;
>
>  > -	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) | crc_enabled ? 1 : 0;
>  > +	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) || crc_enabled ? 1 : 0;
>
> So as I said before, I guess this change is fine, except:
>
> add/remove: 0/0 grow/shrink: 1/0 up/down: 18/0 (18)
> function                                     old     new   delta
> rx_data                                     1237    1255     +18
>
> ie it makes the object code 18 bytes bigger on x86-64 (gcc 4.3.2).
> Given that the code works the same either way, is this change a net win?
>
>  - R.
>   
It does not bother me to leave the code as-is. 

Roel,

Was this found by code inspection or some tool that is run on the code?

