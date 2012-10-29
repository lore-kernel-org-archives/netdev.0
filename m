From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new
 SCTP_GET_ASSOC_STATS call
Date: Mon, 29 Oct 2012 18:19:49 -0400
Message-ID: <20121029221949.GA7546@hmsreliant.think-freely.org>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org>
 <20121026143704.GC25087@hmsreliant.think-freely.org>
 <20121027113541.GA7966@marquez.int.rhx>
 <DB10D819-2751-4467-858A-C4ED1DBED9F4@gmail.com>
 <20121029163808.GB10177@hmsreliant.think-freely.org>
 <508EE306.9080608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michele Baldessari <michele@acksyn.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35637 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933517Ab2J2WUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 18:20:09 -0400
Content-Disposition: inline
In-Reply-To: <508EE306.9080608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 29, 2012 at 04:11:50PM -0400, Vlad Yasevich wrote:
> On 10/29/2012 12:38 PM, Neil Horman wrote:
> >On Sat, Oct 27, 2012 at 11:48:33AM -0400, Vlad Yasevich wrote:
> >>
> >>
> >>
> >>
> >>On Oct 27, 2012, at 7:35 AM, Michele Baldessari <michele@acksyn.org> wrote:
> >>
> >>>Hi Neil & Vlad,
> >>>
> >>>On Fri, Oct 26, 2012 at 10:37:04AM -0400, Neil Horman wrote:
> >>>>We already have files in /proc/net/sctp to count snmp system-wide totals,
> >>>>per-endpoint totals, and per association totals.  Why do these stats differently
> >>>>instead of just adding them the per-association file?  I get that solaris does
> >>>>this, but its not codified in any of the RFC's or other standards.  I would
> >>>>really rather see something like this go into the interfaces we have, rather
> >>>>than creating a new one.
> >>>>
> >>>>I also am a bit confused regarding the stats themselves.  Most are fairly clear,
> >>>>but some seem lacking (you count most things sent and received, but only count
> >>>>received gap acks).  Others seems vague and or confusing (when counting
> >>>>retransmitted chunks and packets, how do you count a packet that has both new
> >>>>and retransmitted chunks)?  And the max observed rto stat is just odd.  Each
> >>>>transport has an rto value, not each association, and you cal already see the
> >>>>individual transport rto values in /proc/net/sctp/remaddr.
> >>>
> >>>thanks a lot for your time reviewing this. I will try to address all
> >>>your comments in a second version of the patch. One thing I am not too
> >>>sure though: do you prefer me extending /proc/net/sctp/* or implement a
> >>>new call.
> >>>
> >>>I ask because from a previous private communication with Vlad the new
> >>>socket option seemed to be the preferred approach.
> >>>I am fine either way just let me know ;)
> >>
> >>
> >>socket option is preferable as /proc doesn't scale very well as number of associations grows.
> >>
> >>-Vlad
> >>
> >I completely agree with that notion, but at the same time, the socket option is
> >limited in that these stats will only be accessible to the process that owns the
> >socket.  I imagine that someone will eventually ask for these stats to be made
> >available to utilities outside of the owning socket.
> >Neil
> 
> I am sure they will, but I know of several applications that as part
> of debugging information periodically fetch the stats.  For them it
> is much simpler to use socket options.
> 
> -vlad
> 
Ok, fair enough.
Neil

> >
> >>>
> >>>cheers,
> >>>--
> >>>Michele Baldessari            <michele@acksyn.org>
> >>>C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
> >>--
> >>To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> >>the body of a message to majordomo@vger.kernel.org
> >>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
