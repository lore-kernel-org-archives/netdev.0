From: Roland Dreier <rdreier@cisco.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Tue, 09 Jun 2009 22:04:21 -0700
Message-ID: <adaski83ciy.fsf@cisco.com>
References: <adaocsx3zaa.fsf@cisco.com>
	<20090609.174504.114047526.davem@davemloft.net>
	<ada1vps4u9e.fsf@cisco.com>
	<20090609.215719.214969588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:58969 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbZFJFET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 01:04:19 -0400
In-Reply-To: <20090609.215719.214969588.davem@davemloft.net> (David Miller's
	message of "Tue, 09 Jun 2009 21:57:19 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > If a facility doesn't exist yet, we're going to have to create
 > one.  It would need to do a downcall to the device when the
 > user joins a multicast group on a socket, and then the device
 > can do whatever magic is necessary to speak multicast immediately
 > and sleep until it really is available for immediate use.

But a send-only membership is created when a multicast packet is sent,
which an application can do just with sendto() -- do we want to plumb
all the way from sendto() down to the device the packet is ultimately
going to be sent on?

There isn't any corresponding code to block an app during ARP
resolution, is there?

 - R.
