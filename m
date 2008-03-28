From: David Miller <davem@davemloft.net>
Subject: Re: Network/block layer race.
Date: Fri, 28 Mar 2008 14:07:36 -0700 (PDT)
Message-ID: <20080328.140736.92315090.davem@davemloft.net>
References: <20080328092036.GA11924@2ka.mipt.ru>
	<20080328.134053.122172549.davem@davemloft.net>
	<20080328205613.GA24812@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: axboe@kernel.dk, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39080
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754308AbYC1VHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:07:39 -0400
In-Reply-To: <20080328205613.GA24812@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Mar 2008 23:56:13 +0300

> Hi.
> 
> On Fri, Mar 28, 2008 at 01:40:53PM -0700, David Miller (davem@davemloft.net) wrote:
> > If content protection is desired, higher level things are needed.
> > For example, SAMBA only uses sendfile() if the remote client
> > has an OP lock on the file in question.
> 
> What I propose is to inform sender about when page is transmitted and
> received on the other side via implicit acks, which are provided already
> by tcp, but is not provided to higher layer.
> We can use it for sendfile and thus do not require higher
> layer 'distributed' locks, i.e. sync some state between hosts to inform
> that data was succesfully received. Patch would be minimal, just export
> sock_wfree() and setup different skb destructor if sk_sock_data is
> provided, that will allow for special users (like the same samba) to use
> ->sendpage() path too (with some changes in the code of course, but that
> is worth whole page copying).

I'd have to see the patch, feel free to submit it :-)
