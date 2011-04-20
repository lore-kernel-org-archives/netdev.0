From: David Miller <davem@davemloft.net>
Subject: Re: Add missing socket check in can/bcm release.
Date: Wed, 20 Apr 2011 12:21:06 -0700 (PDT)
Message-ID: <20110420.122106.242114928.davem@davemloft.net>
References: <20110420033001.GA32635@redhat.com>
	<20110419.203720.02289813.davem@davemloft.net>
	<20110420160350.GA24930@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47375
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753417Ab1DTTVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:21:42 -0400
In-Reply-To: <20110420160350.GA24930@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 20 Apr 2011 12:03:50 -0400

> On Tue, Apr 19, 2011 at 08:37:20PM -0700, David Miller wrote:
>  > From: Dave Jones <davej@redhat.com>
>  > Date: Tue, 19 Apr 2011 23:30:01 -0400
>  > 
>  > > We can get here with a NULL socket argument passed from userspace,
>  > > so we need to handle it accordingly.
>  > > 
>  > > Signed-off-by: Dave Jones <davej@redhat.com>
>  > 
>  > Applied and queued up for -stable, thanks Dave.
> 
> Out of curiousity, while I was asleep it occured to me.. is it ever valid
> for a ->release to get passed a NULL socket->sk ?

Yes, it happens all the time.

If accept() fails mid-stream, we'll have an 'sk' that hasn't been
hooked up to ->socket yet, but we still have to release the 'sk'
in the error handling.

See also commit c100c8f4c3c6f2a407bdbaaad2c4f1062e6a473a, which
fixes a bug triggered via the same code path.
