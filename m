From: marcelo.leitner@gmail.com
Subject: Re: [PATCH] sctp: flush if we can't fit another DATA chunk
Date: Wed, 30 Mar 2016 16:52:54 -0300
Message-ID: <20160330195254.GI3387@mrl.redhat.com>
References: <1459258885-21502-1-git-send-email-marcelo.leitner@gmail.com>
 <20160330.154622.1322506750240048120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752994AbcC3Tw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 15:52:58 -0400
Content-Disposition: inline
In-Reply-To: <20160330.154622.1322506750240048120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 03:46:22PM -0400, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Tue, 29 Mar 2016 10:41:25 -0300
> 
> > There is no point in delaying the packet if we can't fit a single byte
> > of data on it anymore. So lets just reduce the threshold by the amount
> > that a data chunk with 4 bytes (rounding) would use.
> > 
> > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > ---
> >  net/sctp/output.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/sctp/output.c b/net/sctp/output.c
> > index 97745351d58c2fb32b9f9b57d61831d7724d83b2..c518569123ce42a8f21f80754756306c39875013 100644
> > --- a/net/sctp/output.c
> > +++ b/net/sctp/output.c
> > @@ -705,7 +705,8 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
> >  	/* Check whether this chunk and all the rest of pending data will fit
> >  	 * or delay in hopes of bundling a full sized packet.
> >  	 */
> > -	if (chunk->skb->len + q->out_qlen >= transport->pathmtu - packet->overhead)
> > +	if (chunk->skb->len + q->out_qlen >
> > +		maxsize - packet->overhead - sizeof(sctp_data_chunk_t) - 4)
> 
> There is no maxsize in this function.
> 
> You must generate and test your patches against my networking tree.
> 
> Neil, how were you able to see where 'maxsize' is and how it's even
> calculated before determining that this change is correct?
> 
> Please don't ACK patches you really didn't verify in any way at all,
> thanks.  It's better to have no reviews than bad reviews, because ACKs
> are supposed to give me a reason to be more confident in the change.
> 
> Marcelo, I'm ignoring the rest of your SCTP changes, you have to get
> your act together.

Argh, indeed. Bad decision here to split up the patchset. Sorry for that.

  Marcelo
