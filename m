From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: SCTP seems to lose its socket state.
Date: Tue, 17 Jun 2014 07:28:30 -0400
Message-ID: <20140617112830.GC8539@hmsreliant.think-freely.org>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com>
 <063D6719AE5E284EB5DD2968C1650D6D17258A67@AcuExch.aculab.com>
 <063D6719AE5E284EB5DD2968C1650D6D17259993@AcuExch.aculab.com>
 <539638EB.9010802@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725C172@AcuExch.aculab.com>
 <539B4794.4010700@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725CDEF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44430 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374AbaFQL2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 07:28:53 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725CDEF@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 08:40:30AM +0000, David Laight wrote:
> From: Vlad Yasevich
> ...
> > Yeah.  We do end up queuing a bit more commands. Need to see if
> > all them are necessary..
> 
> I wonder why commands get queued, rather than just actioned with
> an immediate function call?
> I suspect it is steeped into the history of the code.
> 
> All of the commands have to be (and are) actioned before any other
> packets (etc) can be processed otherwise there will be massive
> problems with the socket/association state.
> 
> Simply calling the functions is likely change the order of the
> actions - which might break things.
> OTOH direct calls would make it much easier to audit the sequences.
> 
> 	David
> 
That last bit is the point. The stack was written to presume that the state of a
connection would be consistent while the state processing function executed, so
commands were queued to be handled as side effects after that was complete.
There should be no reason you can't call the command functions directly, as long as
you audit each state machine function to ensure it doesn't rely on any state
that the command alters after the call.

Neil

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
