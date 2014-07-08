From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 0/5] SCTP updates
Date: Tue, 8 Jul 2014 07:14:08 -0400
Message-ID: <20140708111408.GA23026@hmsreliant.think-freely.org>
References: <1404507908-6949-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, geirola@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60294 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbaGHLOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 07:14:30 -0400
Content-Disposition: inline
In-Reply-To: <1404507908-6949-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 04, 2014 at 11:05:03PM +0200, Daniel Borkmann wrote:
> This set improves the SCTP socket API to be more in line with
> RFC6458, Geir and myself have finalized it eventually. While
> at it, the first patch also fixes two possible information
> leaks that should go to net tree as well. For more details, I
> refer you to the patches themselves.
> 
> Thanks a lot.
> 
> Daniel Borkmann (1):
>   net: sctp: fix information leaks in ulpevent layer
> 
> Geir Ola Vaagland (4):
>   net: sctp: implement rfc6458, 5.3.4. SCTP_SNDINFO cmsg support
>   net: sctp: implement rfc6458, 5.3.5. SCTP_RCVINFO cmsg support
>   net: sctp: implement rfc6458, 5.3.6. SCTP_NXTINFO cmsg support
>   net: sctp: implement rfc6458, 8.1.31. SCTP_DEFAULT_SNDINFO support
> 
>  include/net/sctp/sctp.h     |   1 +
>  include/net/sctp/structs.h  |   7 +-
>  include/net/sctp/ulpevent.h |  14 +--
>  include/uapi/linux/sctp.h   | 102 ++++++++++++----
>  net/sctp/socket.c           | 285 ++++++++++++++++++++++++++++++++++++++------
>  net/sctp/ulpevent.c         | 185 ++++++++++++----------------
>  6 files changed, 423 insertions(+), 171 deletions(-)
> 
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

since you're adding cmsg's from rfc6458, do you also want to add some
deprecation warnings around the use of SCTP_SNDRCVINFO too, so we can start to
schedule its eventual removal?

Neil
