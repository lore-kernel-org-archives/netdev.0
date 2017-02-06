From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v2 4/6] gtp: consolidate pdp context destruction
 into helper
Date: Mon, 6 Feb 2017 14:58:59 +0100
Message-ID: <20170206135859.mq6pidofidnps2q6@nataraja>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-5-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@netfilter.org>, netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:58519 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753232AbdBFOEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 09:04:39 -0500
Content-Disposition: inline
In-Reply-To: <20170130163713.17524-5-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

On Mon, Jan 30, 2017 at 05:37:11PM +0100, Andreas Schultz wrote:
> Consolidate duplicate code into helper.

Makes complete sense.

However:

> +static void pdp_context_delete(struct pdp_ctx *pctx);
> +

why introduce the forward-declaration and then define the function
further down in the file?  I think in general, it is preferred to put
helper functions on top, before their first use, so forward declarations
can be avoided?  Particularly if the helper function doesn't call any
other functions that are not yet declared at this point.

Please note the above might just be my personal taste, not sure if
that's a general habit in the kernel networking code these days.

So with or without the re-ordering:

Acked-by: Harald Welte <laforge@gnumonks.org>

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
