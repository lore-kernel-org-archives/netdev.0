From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv5 net-next 0/5] sctp: add sender-side procedures for
 stream reconf asoc reset and add streams
Date: Mon, 23 Jan 2017 16:42:17 -0200
Message-ID: <20170123184217.GB3781@localhost.localdomain>
References: <cover.1484993773.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44554 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750742AbdAWSmb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 13:42:31 -0500
Content-Disposition: inline
In-Reply-To: <cover.1484993773.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 21, 2017 at 06:24:21PM +0800, Xin Long wrote:
> Patch 3/5 is to implement sender-side procedures for the SSN/TSN Reset
> Request Parameter described in rfc6525 section 5.1.4, patch 2/5 is
> ahead of it to define a function to make the request chunk for it.
> 
> Patch 5/5 is to implement sender-side procedures for the Add Incoming
> and Outgoing Streams Request Parameter Request Parameter described in
> rfc6525 section 5.1.5 and 5.1.6, patch 4/5 is ahead of it to define a
> function to make the request chunk for it.
> 
> Patch 1/5 is a fix to recover streams states when it fails to send
> request.
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

To make it clear, the notes on v3 patchset also apply to this one, which
are:
- usage of krealloc()
- the removal of __packed attribute

So there should be a v6 of it soon.

Thanks

> 
> Xin Long (5):
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
>  include/linux/sctp.h      |  12 ++++
>  include/net/sctp/sctp.h   |   3 +
>  include/net/sctp/sm.h     |   5 ++
>  include/uapi/linux/sctp.h |   8 +++
>  net/sctp/sm_make_chunk.c  |  75 +++++++++++++++++++++++++
>  net/sctp/socket.c         |  58 +++++++++++++++++++
>  net/sctp/stream.c         | 138 +++++++++++++++++++++++++++++++++++++++++++++-
>  7 files changed, 298 insertions(+), 1 deletion(-)
> 
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
