From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: jumbo frame regression fix
Date: Wed, 03 Oct 2007 00:58:46 -0400
Message-ID: <47032186.40304@pobox.com>
References: <1191372129.26233.12.camel@localhost>	<20071002180209.47c350a3@freepuppy.rosehill>	<4702EB4A.4000208@pobox.com> <20071002215316.0faa7676@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pomac@vapor.com, Linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60246 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150AbXJCE67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 00:58:59 -0400
In-Reply-To: <20071002215316.0faa7676@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 02 Oct 2007 21:07:22 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> Remove unneeded check that caused problems with jumbo frame sizes.
>>> The check was recently added and is wrong.
>>> When using jumbo frames the sky2 driver does fragmentation, so
>>> rx_data_size is less than mtu.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>>>
>>> --- a/drivers/net/sky2.c	2007-10-02 17:56:31.000000000 -0700
>>> +++ b/drivers/net/sky2.c	2007-10-02 17:58:56.000000000 -0700
>>> @@ -2163,9 +2163,6 @@ static struct sk_buff *sky2_receive(stru
>>>  	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
>>>  	prefetch(sky2->rx_ring + sky2->rx_next);
>>>  
>>> -	if (length < ETH_ZLEN || length > sky2->rx_data_size)
>>> -		goto len_error;
>>> -
>> 2.6.23?  2.6.24?  enquiring minds want to know...
> 
> 2.6.23, since it is a regression

You can have regressions in behavior in net-2.6.24.git, too.  _Please_ 
be specific about where you want your patches to go.  Thanks.

	Jeff



