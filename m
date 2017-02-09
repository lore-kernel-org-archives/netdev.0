From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv6 net-next 0/6] sctp: add sender-side procedures for
 stream reconf asoc reset and add streams
Date: Thu, 9 Feb 2017 07:30:10 -0500
Message-ID: <20170209123010.GA25842@hmswarspite.think-freely.org>
References: <cover.1486573727.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46077 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751389AbdBIMc2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 07:32:28 -0500
Content-Disposition: inline
In-Reply-To: <cover.1486573727.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 01:18:14AM +0800, Xin Long wrote:
> Patch 4/6 is to implement sender-side procedures for the SSN/TSN Reset
> Request Parameter described in rfc6525 section 5.1.4, patch 3/6 is
> ahead of it to define a function to make the request chunk for it.
> 
> Patch 6/6 is to implement sender-side procedures for the Add Incoming
> and Outgoing Streams Request Parameter Request Parameter described in
> rfc6525 section 5.1.5 and 5.1.6, patch 5/6 is ahead of it to define a
> function to make the request chunk for it.
> 
> Patch 2/6 is a fix to recover streams states when it fails to send
> request and Patch 1/6 is to drop some unncessary __packed from some
> old structures.
> 
> v1->v2:
>   - put these into a smaller group.
>   - rename some temporary variables in the codes.
>   - rename the titles of the commits and improve some changelogs.
> v2->v3:
>   - re-split the patchset and make sure it has no dead codes for review.
>   - move some codes into stream.c from socket.c.
> v3->v4:
>   - add one more patch to fix a send reset stream request issue.
>   - doing actual work only when request is sent successfully.
>   - reduce some indents in sctp_send_add_streams.
> v4->v5:
>   - close streams before sending request and recover them when sending
>     fails in patch 1/5 and patch 3/5
> v5->v6:
>   - add patch 1/6 to drop some unncessary __packed from some old structures.
>   - remove __packed from some new structures in patch 3/6 and 5/6.
>   - define unsigned int outcnt and incnt to make codes smaller in patch 6/6.
>   - use krealloc instead of kcalloc and remove ksize check in patch 6/6, as
>     ksize check is acutally used in krealloc already.
> 
> Xin Long (6):
>   sctp: drop unnecessary __packed from some stream reconf structures
>   sctp: streams should be recovered when it fails to send request.
>   sctp: add support for generating stream reconf ssn/tsn reset request
>     chunk
>   sctp: implement sender-side procedures for SSN/TSN Reset Request
>     Parameter
>   sctp: add support for generating stream reconf add incoming/outgoing
>     streams request chunk
>   sctp: implement sender-side procedures for Add Incoming/Outgoing
>     Streams Request Parameter
> 
>  include/linux/sctp.h      |  18 +++++--
>  include/net/sctp/sctp.h   |   3 ++
>  include/net/sctp/sm.h     |   5 ++
>  include/uapi/linux/sctp.h |   8 +++
>  net/sctp/sm_make_chunk.c  |  75 ++++++++++++++++++++++++++
>  net/sctp/socket.c         |  58 ++++++++++++++++++++
>  net/sctp/stream.c         | 134 +++++++++++++++++++++++++++++++++++++++++++++-
>  7 files changed, 297 insertions(+), 4 deletions(-)
> 
> -- 
> 2.1.0
> 
> 
For the series
Acked-by: Neil Horman <nhorman@tuxdriver.com>
