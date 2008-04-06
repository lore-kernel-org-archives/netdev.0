From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: add destructor for skb data.
Date: Sun, 6 Apr 2008 13:20:59 +1000
Message-ID: <200804061320.59485.rusty@rustcorp.com.au>
References: <200804052156.05318.rusty@rustcorp.com.au> <20080405130647.GA21337@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37486 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749AbYDFDVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 23:21:20 -0400
In-Reply-To: <20080405130647.GA21337@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 05 April 2008 23:06:48 Evgeniy Polyakov wrote:
> Hi.
>
> On Sat, Apr 05, 2008 at 09:56:05PM +1000, Rusty Russell 
(rusty@rustcorp.com.au) wrote:
> > If we want to notify something when an skb is truly finished (such as
> > for tun vringfd support), we need a destructor on the data.  We don't
> > need to add other fields, since we can just allocate extra room at the
> > end.
>
> There is skb->destructor already, for your case of vringfd it can be
> used safely afaics.

Hi Evgeniy,

    I don't think so.  For a start, the skb destructor is called while the skb 
is still in the socket queue (ie. the data is still live).  Secondly, the 
original skb can be freed while clones still reference the data.

Cheers,
Rusty.
