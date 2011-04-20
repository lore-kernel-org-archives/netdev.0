From: Dave Jones <davej@redhat.com>
Subject: Re: Add missing socket check in can/bcm release.
Date: Wed, 20 Apr 2011 12:03:50 -0400
Message-ID: <20110420160350.GA24930@redhat.com>
References: <20110420033001.GA32635@redhat.com>
 <20110419.203720.02289813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449Ab1DTQDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 12:03:54 -0400
Content-Disposition: inline
In-Reply-To: <20110419.203720.02289813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2011 at 08:37:20PM -0700, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Tue, 19 Apr 2011 23:30:01 -0400
 > 
 > > We can get here with a NULL socket argument passed from userspace,
 > > so we need to handle it accordingly.
 > > 
 > > Signed-off-by: Dave Jones <davej@redhat.com>
 > 
 > Applied and queued up for -stable, thanks Dave.

Out of curiousity, while I was asleep it occured to me.. is it ever valid
for a ->release to get passed a NULL socket->sk ?  I'm wondering if we
can't do this check a layer up in sock_release, in case future protocols
reintroduce the same bug.

>From a quick look, almost every protocol has this check in its ->release.
Though it seems some do something different instead of using socket->sk,
so it would be a pointless check for some of the lesser used ones.

thoughts?

	Dave

