From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix to rejoin multicast groups immediately
Date: Tue, 05 Oct 2010 13:25:25 -0700 (PDT)
Message-ID: <20101005.132525.186293128.davem@davemloft.net>
References: <1285744327-1194-1-git-send-email-fleitner@redhat.com>
	<20101005.001338.52208103.davem@davemloft.net>
	<20101005143430.GA13811@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41007
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755771Ab0JEUZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 16:25:04 -0400
In-Reply-To: <20101005143430.GA13811@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Tue, 5 Oct 2010 11:34:30 -0300

> On Tue, Oct 05, 2010 at 12:13:38AM -0700, David Miller wrote:
>> From: Flavio Leitner <fleitner@redhat.com>
>> Date: Wed, 29 Sep 2010 04:12:07 -0300
>> 
>> > It should rejoin multicast groups immediately when
>> > the failover happens to restore the multicast traffic.
>> > 
>> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
>> 
>> I suspect the IGMPv3 handling via a delayed action, as is currently
>> implemented, is on purpose and is done so to follow the specification
>> of the IGMPv3 RFCs.
>> 
>> Therefore you have to explain why your new behavior is so desirable
>> and in particular why something as undesirable as violating the RFCs
>> is therefore warranted.
> 
> That patch only changes the behavior for bonding during a link
> failure, so if we have a bonding in active-backup or any other mode
> with current-active-slave, the initialization will happen just fine
> following IGMP specs.
> 
> However, neither the backup slave interface nor the backup switch
> connected to backup slave knows about mcast. Thus when a link failure
> happens, we shouldn't rely on timers to not stay out of the mcast
> group losing traffic.
> 
> E.g. The V1 specs says that we shouldn't send any membership report
> if it has been one in the last minute because that means the switch
> is notified and the system will receive mcast traffic for that group. 
> Therefore, if it sees one and a link failure happens right after that,
> the backup slave will send another membership report only one minute
> later. During this time the system loses traffic.

All of this valuable information belongs in the commit log message.

Please resubmit your patch with all of the necessary contextual
information and reasoning explaining in the commit message.

Thanks.
