From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: AW: RFC: replace packets already in queue
Date: Fri, 29 Jun 2012 11:06:57 +0200
Message-ID: <1340960817.15719.6.camel@edumazet-glaptop>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
	 <4FEC854E.8080603@hp.com>
	 <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35815 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab2F2JHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 05:07:01 -0400
Received: by bkcji2 with SMTP id ji2so2761471bkc.19
        for <netdev@vger.kernel.org>; Fri, 29 Jun 2012 02:07:00 -0700 (PDT)
In-Reply-To: <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-29 at 08:46 +0000, Erdt, Ralph wrote:
> Hello Rick Jones,
> 
> > You might want to try the recent "codel" additions to the stack.  They
> > seek to keep the size of queues more manageable while still allowing
> > the occasional burst.
> Thank you for your hint. This is surly a needful solution in normal network, but this didn't help us:
> We are working with very heterogeneous networks:
> Internal: 100MBit and more.
> Extern: 9,6*K*Bit and LESS(*), and shared, and...
> A few other information: wireless (higher packet loss rate), medium access time > 100ms, RTT (standard ping) with IDLE network: 1,5 *seconds*, RTT with network load: minutes(!), and so on. Just very shocking..
> 
> TCP isn't usable over such a link. So we are only sending UDP. The codel didn't help us, as codel addresses the flow speed. It's dropping "randomly" (I know it's not random in the lower level, but it's random from the application's perspective) packets. 
> 
> I'm addressing the amount of information: Trying to reduce it intelligently by REPLACING old packets with new ones.. Surely - the application must handle this. But in such a network a administrator have to configure the queues and he knows the applications.
> In one private mail someone guesses that we are making VoIP. No - we just want to send status information (e.g. sensor information) which will get deprecated, when a new information is available.
> 
> I know, this is a very special problem, which didn't occur in normal or even abnormal situations. But I'm sure there are some other people having the this problem, too. So I'm glad to share my solution.
> 
> (*you remember the good ol' times with modems over telephone lines? When the internet was called BBS? And how it suddenly feels, when the BBS starts using ANSI? This was comfortable compared to our problem..)

Problem is : with wireless, chances are high that the old packet is not
waiting in qdisc, but in wireless queues.

Anyway, adding a maxdelay to codel / fq_codel is really easy : This
would drop packet if its sejourn time is above a given limit.

You could use codel with @target being greater than @maxdelay to remove
all probabilistic drops, and only keep the @maxdelay behavior.

If you want I can cook this patch.
