From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH net-next 2/2] xen-netback: handle frontends that fail
 to transition through Closing
Date: Fri, 20 Sep 2013 14:38:46 +0100
Message-ID: <523C4FE6.30309@citrix.com>
References: <1379681791-21842-1-git-send-email-paul.durrant@citrix.com> <1379681791-21842-3-git-send-email-paul.durrant@citrix.com> <20130920133448.GC457@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43441 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754590Ab3ITNit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 09:38:49 -0400
In-Reply-To: <20130920133448.GC457@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/09/13 14:34, Wei Liu wrote:
> On Fri, Sep 20, 2013 at 01:56:31PM +0100, Paul Durrant wrote:
>> Some old Windows frontends fail to transition through the xenbus Closing
>> state and move directly from Connected to Closed. Handle this case properly.
>>
>> --- a/drivers/net/xen-netback/xenbus.c
>> +++ b/drivers/net/xen-netback/xenbus.c
>> @@ -265,6 +265,8 @@ static void frontend_changed(struct xenbus_device *dev,
>>  		break;
>>  
>>  	case XenbusStateClosed:
>> +		if (dev->state == XenbusStateConnected)
>> +			disconnect_backend(dev);
> 
> Could you please add a comment above this change stating that this is a
> workaround for some old frontend that we cannot fix / upgrade.

Handling frontend CONNECTED -> CLOSED is a sensible thing for a backend
to do regardless of whether there are old frontends that do this or not.

> We would still like to later frontend goes through the normal connected
> -> closing -> closed path.

This should be documented as a full description of the two state
machines in public/io/netif.h in Xen.  Not scattered about in comments
in a particular backend implementation.

David
