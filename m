From: Alexander Zimmermann <zimmermann@nets.rwth-aachen.de>
Subject: Re: [net-next PATCH v4 1/3] net: TCP thin-stream detection
Date: Sun, 21 Feb 2010 12:23:55 +0100
Message-ID: <D40945A6-301D-485D-BB8C-826D2EB68DA4@nets.rwth-aachen.de>
References: <4B7AAE60.3070305@simula.no> <20100221102102.GB1311@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <Arnd.Hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com,
	Lukowski Damian <damian@tvk.rwth-aachen.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Pavel Machek <pavel@ucw.cz>, Andreas Petlund <apetlund@simula.no>,
	lars.eggert@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:59237 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751398Ab0BULX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2010 06:23:57 -0500
In-reply-to: <20100221102102.GB1311@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am 21.02.2010 um 11:21 schrieb Pavel Machek:

> Hi!
> 
>> +After analysing a large number of time-dependent interactive
>> +applications, we have seen that they often produce thin streams
>> +and also stay with this traffic pattern throughout its entire
>> +lifespan. The combination of time-dependency and the fact that the
>> +streams provoke high latencies when using TCP is unfortunate.
>> +
>> +In order to reduce application-layer latency when packets are lost,
>> +a set of mechanisms has been made, which address these latency issues
>> +for thin streams. In short, if the kernel detects a thin stream,
>> +the retransmission mechanisms are modified in the following manner:
>> +
>> +1) If the stream is thin, fast retransmit on the first dupACK.
>> +2) If the stream is thin, do not apply exponential backoff.
> 
> 2) seems very dangerous/unfair. If network  congestion is caused just
> by thin streams, will the network just fall apart?

and 1) can also be dangerous if we have reordering on the path.

I strongly suggest that we discuss Andreas' idea on IETF TCPM *before*
we integrate it in the kernel and enable it for everyone

Alex,

as an netdev reader and TCPM member

> 
> 
> -- 
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22220
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//

