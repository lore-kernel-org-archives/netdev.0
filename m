From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 8/8] [PATCH v2] [CCID3]: Interface CCID3 code with
	newer Loss Intervals Database
Date: Wed, 12 Dec 2007 15:05:23 -0200
Message-ID: <20071212170523.GT24046@ghostprotocols.net>
References: <11971083883685-git-send-email-gerrit@erg.abdn.ac.uk> <1197108388630-git-send-email-gerrit@erg.abdn.ac.uk> <11971083883727-git-send-email-gerrit@erg.abdn.ac.uk> <11971083882049-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881748-git-send-email-gerrit@erg.abdn.ac.uk> <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk> <20071210210416.GB24046@ghostprotocols.net> <20071211094238.GA9926@gerrit.erg.abdn.ac.uk> <20071211172244.GF24046@ghostprotocols.net> <20071212165632.GB2282@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757464AbXLLRF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 12:05:28 -0500
Content-Disposition: inline
In-Reply-To: <20071212165632.GB2282@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Dec 12, 2007 at 04:56:32PM +0000, Gerrit Renker escreveu:
> | This time around I'm not doing any reordering, just trying to use your
> | patches as is, but adding this patch as-is produces a kernel that will
> | crash, no?
> | 
> | > The loss history and the RX/TX packet history slabs are all created in
> | > tfrc.c using the three different __init routines of the dccp_tfrc_lib.
> | 
> | Yes, the init routines are called and in turn they create the slab
> | caches, but up to the patch "[PATCH 8/8] [PATCH v2] [CCID3]: Interface
> | CCID3 code with newer Loss Intervals Database" the new li slab is not
> | being created, no? See what I'm talking?
> | 
> Sorry, there is some weird kind of mix-up going on. Can you please check
> your patch set: it seems this email exchange refers to an older variant.
> In the most recent patch set, the slab is introduced in the patch
> 
> 	[TFRC]: Ringbuffer to track loss interval history
> 
> --- a/net/dccp/ccids/lib/loss_interval.c
> +++ b/net/dccp/ccids/lib/loss_interval.c
> @@ -27,6 +23,54 @@ struct dccp_li_hist_entry {
>         u32              dccplih_interval;
>  };
> 
> +static struct kmem_cache  *tfrc_lh_slab  __read_mostly;	/* <=== */

Yup, this one, is introduced as above but is not initialized at the
module init routine, please see, it should be OK and we can move on:

http://git.kernel.org/?p=linux/kernel/git/acme/net-2.6.25.git;a=commitdiff;h=a925429ce2189b548dc19037d3ebd4ff35ae4af7

> +/* Loss Interval weights from [RFC 3448, 5.4], scaled by 10 */
> +static const int tfrc_lh_weights[NINTERVAL] = { 10, 10, 10, 10, 8, 6, 4, 2 };
> // ...
> 
> And this is 6/8, i.e. before 8/8, cf.
> 	http://www.mail-archive.com/dccp@vger.kernel.org/msg03000.html
>      
> I don't know which tree you are working off, would it be possible to
> check against the test tree
> 	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[dccp]

I'm doing a fresh clone now. But I think that everything is OK after
today's merge request I sent to David.

- Arnaldo
