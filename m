From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2] sctp: Enforce retransmission limit during shutdown
Date: Wed, 6 Jul 2011 10:19:02 -0400
Message-ID: <20110706141902.GB19518@hmsreliant.think-freely.org>
References: <4E0B3491.1060603@hp.com>
 <20110629143649.GC10085@canuck.infradead.org>
 <4E0B3DA1.9060200@hp.com>
 <20110629154814.GD10085@canuck.infradead.org>
 <4E0B4F71.4020108@hp.com>
 <20110630084933.GA24074@canuck.infradead.org>
 <4E0C8368.5090502@hp.com>
 <20110704135019.GA801@canuck.infradead.org>
 <20110706121508.GA19518@hmsreliant.think-freely.org>
 <1309958184.12098.111.camel@lsx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vladislav Yasevich <vladislav.yasevich@hp.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: Thomas Graf <tgraf@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45978 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab1GFOTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 10:19:16 -0400
Content-Disposition: inline
In-Reply-To: <1309958184.12098.111.camel@lsx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 06, 2011 at 03:16:24PM +0200, Thomas Graf wrote:
> On Wed, 2011-07-06 at 08:15 -0400, Neil Horman wrote: 
> > On Mon, Jul 04, 2011 at 09:50:19AM -0400, Thomas Graf wrote:
> 
> > > --- a/net/sctp/sm_statefuns.c
> > > +++ b/net/sctp/sm_statefuns.c
> > > @@ -5154,7 +5154,7 @@ sctp_disposition_t sctp_sf_do_9_2_start_shutdown(
> > >  	 * The sender of the SHUTDOWN MAY also start an overall guard timer
> > >  	 * 'T5-shutdown-guard' to bound the overall time for shutdown sequence.
> > >  	 */
> > > -	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
> > > +	sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_RESTART,
> > >  			SCTP_TO(SCTP_EVENT_TIMEOUT_T5_SHUTDOWN_GUARD));
> > >  
> > How come you're modifying this chunk to use TIMER_RESTART rather than
> > TIMER_START? start shutdown is where the t5 timer is actually started, isn't it?
> 
> Since we also start the timer in SHUTDOWN_PENDING now if we hit
> the retransmission limit the timer may be running already and
> needs to be restarted (at least in theory).
> 
> In reality the timer should be stopped though, we can only go
> from SHUTDOWN_PENDING into SHUTDOWN by actually SACKing bytes which
> will delete the timer. This may change though and I did not want
> this to bite us later on.
> 
> 
> 
Ok, makes sense
Acked-by: Neil Horman <nhorman@tuxdriver.com>

