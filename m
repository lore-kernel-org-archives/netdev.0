From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH v2 0/3][BUG-FIX]: Test tree updates and bug fixes
Date: Wed, 5 Dec 2007 12:23:21 -0200
Message-ID: <20071205142321.GH4653@ghostprotocols.net>
References: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk> <11968535864083-git-send-email-gerrit@erg.abdn.ac.uk> <11968535861091-git-send-email-gerrit@erg.abdn.ac.uk> <11968535861367-git-send-email-gerrit@erg.abdn.ac.uk> <20071205132345.GC4653@ghostprotocols.net> <20071205135511.GD893@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48503 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344AbXLEOXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 09:23:25 -0500
Content-Disposition: inline
In-Reply-To: <20071205135511.GD893@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Dec 05, 2007 at 01:55:11PM +0000, Gerrit Renker escreveu:
> | > @@ -788,8 +782,8 @@ static void ccid3_hc_rx_packet_recv(stru
> | >  	if (unlikely(hcrx->ccid3hcrx_state == TFRC_RSTATE_NO_DATA)) {
> | >  		if (is_data_packet) {
> | >  			do_feedback = FBACK_INITIAL;
> | > +			hcrx->ccid3hcrx_s = payload_size;
> | >  			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
> | > -			ccid3_hc_rx_update_s(hcrx, payload_size);
> | 
> | We have to set ccid3hcrx_bytes_recv to the payload_size here too, I'm
> | fixing this on the reworked patch that introduces the RX history.
> | 
> I almost did the same error again by wanting to agree too prematurely.
> 
> But updating ccid3hcrx_bytes_recv is in fact not needed here and if it
> would be done it would not have a useable effect. The reason is that the
> first data packet will trigger the initial feedback; and in the initial
> feedback packet X_recv (which is ccid3hcrx_bytes_recv / the_time_spent)
> is set to 0 (RFC 3448, 6.3).
> 
> For this reason, updating bytes_recv for the first data packet is also not
> in the flowchart on 
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/

OK, I will add a comment on the code stating why it is not needed so
that new people don't commit the same mistake again.

- Arnaldo
