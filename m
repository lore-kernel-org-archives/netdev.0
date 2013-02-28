From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 4/4] sctp: fix association hangs due to partial
 delivery errors
Date: Thu, 28 Feb 2013 09:34:26 -0500
Message-ID: <20130228143426.GD23518@shamino.rdu.redhat.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
 <1361991273-30578-5-git-send-email-lee.roberts@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Lee A. Roberts" <lee.roberts@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37505 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616Ab3B1Oee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 09:34:34 -0500
Content-Disposition: inline
In-Reply-To: <1361991273-30578-5-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, 2013 at 11:54:33AM -0700, Lee A. Roberts wrote:
> From: "Lee A. Roberts" <lee.roberts@hp.com>
> 
> Resolve SCTP association hangs observed during SCTP stress
> testing.  Observable symptoms include communications hangs
> with data being held in the association reassembly and/or lobby
> (ordering) queues.  Close examination of reassembly queue shows
> missing packets.
> 
> In sctp_ulpq_tail_data(), use return values 0,1 to indicate whether
> a complete event (with MSG_EOR set) was delivered.  A return value
> of -ENOMEM continues to indicate an out-of-memory condition was
> encountered.
> 
> In sctp_ulpq_retrieve_partial() and sctp_ulpq_retrieve_first(),
> correct message reassembly logic for SCTP partial delivery.
> Change logic to ensure that as much data as possible is sent
> with the initial partial delivery and that following partial
> deliveries contain all available data.
> 
> In sctp_ulpq_partial_delivery(), attempt partial delivery only
> if the data on the head of the reassembly queue is at or before
> the cumulative TSN ACK point.
> 
> In sctp_ulpq_renege(), use the modified return values from
> sctp_ulpq_tail_data() to choose whether to attempt partial
> delivery or to attempt to drain the reassembly queue as a
> means to reduce memory pressure.  Remove call to
> sctp_tsnmap_mark(), as this is handled correctly in call to
> sctp_ulpq_tail_data().
> 
> Signed-off-by: Lee A. Roberts <lee.roberts@hp.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 
