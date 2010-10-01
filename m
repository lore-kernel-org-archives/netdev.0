From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 0/8] tg3: Bugfixes and updates
Date: Fri, 1 Oct 2010 10:25:45 -0700
Message-ID: <20101001172545.GA17223@mcarlson.broadcom.com>
References: <1285878877-12148-1-git-send-email-mcarlson@broadcom.com>
 <20101001.002628.267960834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2554 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab0JARcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 13:32:12 -0400
In-Reply-To: <20101001.002628.267960834.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 01, 2010 at 12:26:28AM -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Thu, 30 Sep 2010 13:34:29 -0700
> 
> > This patchset implements some bugfixes, removes the 5724 device
> > ID and introduces extended rx buffer rings.
> 
> All applied....
> 
> But really, I want to hear some real justification for a 2048 entry RX
> ring at gigabit speeds.  I even think 512 is way too large for gigabit
> parts.

I don't have any personal experience where a larger ring size could
benefit.  However, I have heard of situations in the past where people
have said increasing the amount of rx buffers available has smoothed
over some bursty traffic / cpu usage patterns.  These people really did
want more than 512 rx buffers.

> Any machine that gets one of these newer 5717 parts does not need that
> much queueing, and too deep queues tend to hurt locality and thus
> performance.

Good point.  I'll see if we can scale the BD ring size based on the
number of rx buffers the administrator has configured.

