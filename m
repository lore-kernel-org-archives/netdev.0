From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: SWS for rcvbuf < MTU
Date: Fri, 2 Mar 2007 15:21:58 -0500
Message-ID: <200703021521.58821.alexandre.sidorenko@hp.com>
References: <200703021128.29208.alexandre.sidorenko@hp.com> <20070302.112542.18305896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:46664 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965569AbXCBUVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 15:21:45 -0500
In-Reply-To: <20070302.112542.18305896.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On March 2, 2007 02:25:42 pm David Miller wrote:
> From: Alex Sidorenko <alexandre.sidorenko@hp.com>
> Date: Fri, 2 Mar 2007 11:28:28 -0500
>
> > Customer has confirmed that this resolves the problem and decreases
> > CPU usage by his custom application - even when there is no SWS.
>
> There is rarely ever a reason to set explicit socket receive
> buffer sizes, since the kernel dynamically sizes them based
> upon how the connection is used.
>
> Why do they set it so low?
>
> It is just as easy to fix their performance bug by simply removing
> SO_RCVBUF setting in the application.

Hi David,

they told us that they use small rcvbuf to throttle bandwidth for this 
application. I explained it would be better to use TC for this purpose. They 
agreed and will probably redesign their application in the future, but they 
cannot do it right now. For the same reason they have to use the old 2.4.20 
for a while - in big companies the important production software cannot be 
changed quickly. 

The fix I suggested is trivial and should have no impact the case of 
rcvfbuf>mtu, so I think it makes sense to include it in upstream kernel.

Regards,
Alex


-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: alexs@hplinux.canada.hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
