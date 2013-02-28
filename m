From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 1/4] sctp: fix association hangs due to off-by-one
 errors in sctp_tsnmap_grow()
Date: Thu, 28 Feb 2013 09:31:47 -0500
Message-ID: <20130228143146.GA23518@shamino.rdu.redhat.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
 <1361991273-30578-2-git-send-email-lee.roberts@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Lee A. Roberts" <lee.roberts@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37444 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986Ab3B1Ob6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 09:31:58 -0500
Content-Disposition: inline
In-Reply-To: <1361991273-30578-2-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, 2013 at 11:54:30AM -0700, Lee A. Roberts wrote:
> From: "Lee A. Roberts" <lee.roberts@hp.com>
> 
> Resolve SCTP association hangs observed during SCTP stress
> testing.  Observable symptoms include communications hangs
> with data being held in the association lobby (ordering)
> queue.  Close examination of reassembly/ordering queues shows
> duplicated packets.
> 
> In sctp_tsnmap_mark(), correct off-by-one error when calculating
> size value for sctp_tsnmap_grow().
> 
> In sctp_tsnmap_grow(), correct off-by-one error when copying
> and resizing the tsnmap.  If max_tsn_seen is in the LSB of the
> word, this bit can be lost, causing the corresponding packet
> to be transmitted again and to be entered as a duplicate into
> the SCTP reassembly/ordering queues.  Change parameter name
> from "gap" (zero-based index) to "size" (one-based) to enhance
> code readability.
> 
> Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
