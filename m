From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2] net: sctp: sctp_verify_init: clean up mandatory
 checks and add comment
Date: Tue, 27 Aug 2013 18:23:30 +0400
Message-ID: <521CB662.3050903@cogentembedded.com>
References: <1377612363-10779-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:54826 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062Ab3H0OXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 10:23:35 -0400
Received: by mail-la0-f52.google.com with SMTP id ev20so3461436lab.25
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 07:23:34 -0700 (PDT)
In-Reply-To: <1377612363-10779-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 27-08-2013 18:06, Daniel Borkmann wrote:

> Add a comment related to RFC4960 explaning why we do not check for initial
> TSN, and while at it, remove yoda notation checks and clean up code from
> checks of mandatory conditions. That's probably just really minor, but makes
> reviewing easier.

> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>   v1->v2: update comment as Neil suggested

>   net/sctp/sm_make_chunk.c | 26 ++++++++++++--------------
>   1 file changed, 12 insertions(+), 14 deletions(-)

> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 01e9783..e1c1531 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -2240,25 +2240,23 @@ int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
>   		     struct sctp_chunk **errp)
>   {
>   	union sctp_params param;
> -	int has_cookie = 0;
> +	bool has_cookie = false;
>   	int result;
>
> -	/* Verify stream values are non-zero. */
> -	if ((0 == peer_init->init_hdr.num_outbound_streams) ||
> -	    (0 == peer_init->init_hdr.num_inbound_streams) ||
> -	    (0 == peer_init->init_hdr.init_tag) ||
> -	    (SCTP_DEFAULT_MINWINDOW > ntohl(peer_init->init_hdr.a_rwnd))) {
> -
> +	/* Check for missing mandatory parameters. Note: Initial TSN is
> +	 * also mandatory, but is not checked here since the valid range
> +	 * is 0..2**(32-1). RFC4960, section 3.3.3.

    I don't think you really meant 2**(32-1) == 2**31. Previously you wrote 
2**32-1.

WBR, Sergei
