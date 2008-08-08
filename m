From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Strange tg3 regression with UMP fw. link reporting
Date: Fri, 08 Aug 2008 08:20:04 -0700
Message-ID: <1218208804.12081.14.camel@HP1>
References: <1218180939.24157.332.camel@pasglop>
 <31233EB5-037E-4615-95C9-7C816E510752@kernel.crashing.org>
 <1218187111.24157.336.camel@pasglop>
 <20080808184359.GB23249@HP-xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"Segher Boessenkool" <segher@kernel.crashing.org>,
	"linuxppc-dev list" <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>, "Nathan Lynch" <ntl@pobox.com>
To: "Matthew Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3379 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759266AbYHHTVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 15:21:34 -0400
In-Reply-To: <20080808184359.GB23249@HP-xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-08-08 at 11:43 -0700, Matthew Carlson wrote:
> Segher is right.  The code should be 2.5 milliseconds but is actually
> much longer.  This fix is actually already in my patch queue and needs
> to be sent upstream.
> 

Matt, I think we can optimize this a little more.  The heart beat event
is sent every second and the link event is sent whenever the link
changes.  the spin wait is only needed in rare cases when the link event
is closer than 2.5 msec from the heart beat event.

We can save the jiffies time stamp right after sending each event.  Next
time we need to send a heart beat or a link event, we check the jiffies
with the stored time stamp.  If they are less than 2.5 msec apart and we
haven't received the ACK from the previous event yet, we just wait up to
the remainder.  It should be very rare that we have to wait.


