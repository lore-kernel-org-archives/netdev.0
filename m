From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next stable] sctp: fully initialize sctp_outq in sctp_outq_init
Date: Wed, 12 Jun 2013 17:51:08 +0400
Message-ID: <51B87CCC.4030200@cogentembedded.com>
References: <1371041959-17697-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:57448 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754268Ab3FLNvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 09:51:17 -0400
Received: by mail-la0-f42.google.com with SMTP id eb20so7894651lab.29
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 06:51:16 -0700 (PDT)
In-Reply-To: <1371041959-17697-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-06-2013 16:59, Neil Horman wrote:

> In commit 2f94aabd9f6c925d77aecb3ff020f1cc12ed8f86, we modified

     Please also specify that commit's summary line in parens.

> sctp_outq_teardown to use sctp_outq_init to fully re-initalize the outq
> structure.  Steve West recently asked me why I removed the q->error = 0
> initalization from sctp_outq_teardown.  I did so because I was operating under
> the impression that sctp_outq_init would properly initalize that value for us,
> but it doesn't.  sctp_outq_init operates under the assumption that the outq
> struct is all 0's (as it is when called from sctp_association_init), but using
> it in __sctp_outq_teardown violates that assumption. We should do a memset in
> sctp_outq_init to ensure that the entire structure is in a known state there
> instead.

> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: "West, Steve (NSN - US/Fort Worth)" <steve.west@nsn.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: netdev@vger.kernel.org
> CC: davem@davemloft.net
> ---
>   net/sctp/outqueue.c | 7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index 32a4625..d8b6958 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -206,6 +206,9 @@ static inline int sctp_cacc_skip(struct sctp_transport *primary,
>    */
>   void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
>   {
> +

    Why empty line here?

> +	memset(q, 0, sizeof(struct sctp_outq));
> +

    sizeof(*q) would have been shorter...

WBR, Sergei
