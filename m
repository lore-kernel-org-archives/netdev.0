From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] SCTP: Reduce log spamming for sctp setsockopt
Date: Mon, 16 Dec 2013 11:04:40 -0500
Message-ID: <20131216160440.GE19809@hmsreliant.think-freely.org>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
 <1387206233.18217.21.camel@joe-AO722>
 <52AF18B7.6050602@redhat.com>
 <1387207301.18217.30.camel@joe-AO722>
 <52AF2001.2090108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39321 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753999Ab3LPQEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 11:04:51 -0500
Content-Disposition: inline
In-Reply-To: <52AF2001.2090108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 04:45:05PM +0100, Daniel Borkmann wrote:
> On 12/16/2013 04:21 PM, Joe Perches wrote:
> >On Mon, 2013-12-16 at 16:13 +0100, Daniel Borkmann wrote:
> >>On 12/16/2013 04:03 PM, Joe Perches wrote:
> >>>On Mon, 2013-12-16 at 09:44 -0500, Neil Horman wrote:
> >>>>During a recent discussion regarding some sctp socket options, it was noted that
> >>>>we have several points at which we issue log warnings that can be flooded at an
> >>>>unbounded rate by any user.  Fix this by converting all the pr_warns in the
> >>>>sctp_setsockopt path to be pr_warn_ratelimited.
> >>>
> >>>trivial note:
> >>[...]
> >>>>@@ -5311,8 +5311,8 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
> >>>[]
> >>>>+		pr_warn_ratelimited("Use of int in max_burst socket option deprecated\n");
> >>>>+		pr_warn_ratelimited("Use struct sctp_assoc_value instead\n");
> >>>
> >>>Perhaps a dedicated "deprecated" warning function
> >>>to centralize these?
> >>>
> >>>void _sctp_warn_deprecated(const char *func, const char *from, const char *to);
> >>>{
> >>>	etc.
> >>>}
> >>>#define sctp_warn_deprecated(from, to)		\
> >>>	_sctp_warn_deprecated(__func__, from, to)
> >>
> >>If so, then this should better get even more "centralized" ... as e.g.
> >>pr_warn_deprecated() [which internally is ratelimited]. I don't see the
> >>point why only SCTP should have this special-cased.
> >
> >Sure, if it's useful outside of sctp, but I didn't
> >notice any other uses like it.
> 
> If we have a generic API for that, they might come, sure.
I agree with Daniel.  If we're going to make this common, theres no reason to
not make it common for all uses.  Searching the kernel for uses of printk/pr_*
and the string "deprecated" shows lots of potential use sites.

Neil

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
