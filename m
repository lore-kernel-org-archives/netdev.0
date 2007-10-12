From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 03/12] Prevent renaming interfaces to empty string.
Date: Fri, 12 Oct 2007 10:07:43 -0700
Message-ID: <20071012100743.0c1a11f8@freepuppy.rosehill>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
	<1192179407-22461-2-git-send-email-andreas@fatal.se>
	<1192179407-22461-3-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>,
	Andreas Henriksson <andreas@fatal.se>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55879 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933227AbXJLRJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 13:09:07 -0400
In-Reply-To: <1192179407-22461-3-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007 10:56:38 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> From: Alexander Wirt <formorer@debian.org>
> 
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> ---
>  ip/iplink.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/ip/iplink.c b/ip/iplink.c
> index 4060845..da1f64e 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -670,6 +670,10 @@ static int do_set(int argc, char **argv)
>  	}
>  
>  	if (newname && strcmp(dev, newname)) {
> +		if (strlen(newname) == 0) {
> +		    printf("\"\" is not valid device identifier\n");
> +		    return -1;
> +		}
>  		if (do_changename(dev, newname) < 0)
>  			return -1;
>  		dev = newname;

The kernel should already be preventing this?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
