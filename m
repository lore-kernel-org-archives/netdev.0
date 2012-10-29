From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] sctp: Clean up type-punning in sctp_cmd_t union
Date: Mon, 29 Oct 2012 12:35:44 -0400
Message-ID: <20121029163544.GA10177@hmsreliant.think-freely.org>
References: <1351198075-20385-1-git-send-email-nhorman@tuxdriver.com>
 <1351258876-32078-1-git-send-email-nhorman@tuxdriver.com>
 <508AE0B6.2020506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57451 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932627Ab2J2Qf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 12:35:56 -0400
Content-Disposition: inline
In-Reply-To: <508AE0B6.2020506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 26, 2012 at 03:12:54PM -0400, Vlad Yasevich wrote:
> On 10/26/2012 09:41 AM, Neil Horman wrote:
> >Lots of points in the sctp_cmd_interpreter function treat the sctp_cmd_t arg as
> >a void pointer, even though they are written as various other types.  Theres no
> >need for this as doing so just leads to possible type-punning issues that could
> >cause crashes, and if we remain type-consistent we can actually just remove the
> >void * member of the union entirely.
> >
> >Change Notes:
> >
> >v2)
> >	* Dropped chunk that modified SCTP_NULL to create a marker pattern
> >	 should anyone try to use a SCTP_NULL() assigned sctp_arg_t, Assigning
> >	 to .zero provides the same effect and should be faster, per Vlad Y.
> >
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com
> >CC: Vlad Yasevich <vyasevich@gmail.com>
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
> 
> -vlad
> 
Thanks for the ACk Vlad, do you have any thoughts regarding Dave M's comments
above on this .zero/memset question?  He makes a good point regarding complete
initalization I think.
Neil
