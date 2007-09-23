From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: pktgen question
Date: Sun, 23 Sep 2007 12:55:19 -0500
Message-ID: <46F6A887.1030301@opengridcomputing.com>
References: <46F6905C.6030309@opengridcomputing.com> <20070923172803.GA11997@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:50436 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754571AbXIWRzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 13:55:19 -0400
In-Reply-To: <20070923172803.GA11997@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Evgeniy Polyakov wrote:
> Hi Steve.
> 
> On Sun, Sep 23, 2007 at 11:12:12AM -0500, Steve Wise (swise@opengridcomputing.com) wrote:
>> The pktgen module provides a way to "clone" the skb its using for 
>> transmission, and allows passing N clones of the originally created skb 
>> to the driver under test.    However, it doesn't really use skb_clone(), 
>> but rather it just bumps the skb->users count for each "clone" and 
>> passes the same skb ptr to the driver.
>>
>> Q: Is that a valid use of skb->users or should pktgen really be cloning 
>> the skbuff?
> 
> It's a hack, but since skb is owned by pktgen only (no copies in some
> outside queues or some other access) it is allowed just to bump reference
> counter (i.e. 'share' skb in usual notation).
>

Its a hack that breaks cxgb3 because cxgb3 uses the skb->cb area for 
each skb passed down.  So cxgb3 is at fault then?  IE a driver cannot 
use the skb->cb field if the users count is > 1?  Or maybe a driver can 
_never_ use the cb field?

Steve.




