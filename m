From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/3] net: sctp: sctp_association_init: hold refs
 in reverse order
Date: Sat, 8 Jun 2013 20:21:59 -0400
Message-ID: <20130609002159.GB5386@neilslaptop.think-freely.org>
References: <1370594106-25745-1-git-send-email-dborkman@redhat.com>
 <1370594106-25745-3-git-send-email-dborkman@redhat.com>
 <20130607110054.GB3249@hmsreliant.think-freely.org>
 <51B1C650.2000603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50213 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab3FIAWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 20:22:09 -0400
Content-Disposition: inline
In-Reply-To: <51B1C650.2000603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 07, 2013 at 01:38:56PM +0200, Daniel Borkmann wrote:
> On 06/07/2013 01:00 PM, Neil Horman wrote:
> >On Fri, Jun 07, 2013 at 10:35:05AM +0200, Daniel Borkmann wrote:
> >>In case we need to bail out for whatever reason during assoc
> >>init, we call sctp_endpoint_put() and then sock_put(), however,
> >>we've hold both refs in reverse order, so first sctp_endpoint_hold()
> >>and then sock_hold(). Reverse this, so that we have sock_hold()
> >>with sctp_endpoint_hold() first and then in error case
> >>sctp_endpoint_put() and then sock_put(). Actually shouldn't
> >>matter much since we just increase an atomic, but that way, it's
> >>more clean.
> >>
> >>Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> >>---
> >>  net/sctp/associola.c | 5 ++---
> >>  1 file changed, 2 insertions(+), 3 deletions(-)
> >>
> >>diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> >>index 91cfd8f..04795fb 100644
> >>--- a/net/sctp/associola.c
> >>+++ b/net/sctp/associola.c
> >>@@ -86,11 +86,10 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
> >>
> >>  	/* Discarding const is appropriate here.  */
> >>  	asoc->ep = (struct sctp_endpoint *)ep;
> >>-	sctp_endpoint_hold(asoc->ep);
> >>-
> >>-	/* Hold the sock.  */
> >>  	asoc->base.sk = (struct sock *)sk;
> >>+
> >>  	sock_hold(asoc->base.sk);
> >>+	sctp_endpoint_hold(asoc->ep);
> >>
> >>  	/* Initialize the common base substructure.  */
> >>  	asoc->base.type = SCTP_EP_TYPE_ASSOCIATION;
> >
> >This looks good, but you may want to instead reverse the order in which we do
> >the puts at fail_init, as other call sites that hold both endpoint socket do so
> >in endpoint, sock order, and it would probably be nice to be consistent in that
> >order.
> 
> Thanks, will do. When we have clarified the 1st patch, I'll simply respin the
> entire patchset and send a v2.
> 
Sounds great, thanks.  Just FYI, I'm out of town so may not respond super fast.
Will do my best though.
Neil
