From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Check getline() return code correctly
Date: Mon, 11 Jul 2011 10:37:33 -0700
Message-ID: <20110711103733.7190571b@nehalam.ftrdhcpuser.net>
References: <1307710167-28868-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petr Sabata <contyk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37832 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758287Ab1GKRhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 13:37:32 -0400
In-Reply-To: <1307710167-28868-1-git-send-email-contyk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jun 2011 14:49:27 +0200
Petr Sabata <contyk@redhat.com> wrote:

> The current implementation is always false, no matter what happens.
> 
> Signed-off-by: Petr Sabata <contyk@redhat.com>
> ---
>  lib/utils.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/utils.c b/lib/utils.c
> index 1b42222..76cadea 100644
> --- a/lib/utils.c
> +++ b/lib/utils.c
> @@ -702,7 +702,7 @@ ssize_t getcmdline(char **linep, size_t *lenp, FILE *in)
>  		size_t len1 = 0;
>  		size_t cc1;
>  
> -		if ((cc1 = getline(&line1, &len1, in)) < 0) {
> +		if ((cc1 = getline(&line1, &len1, in)) == (size_t)-1) {
>  			fprintf(stderr, "Missing continuation line\n");
>  			return cc1;
>  		}

The correct fix is to make cc1 a signed variable.
