From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] arpd: drop unnecessary explicit null
 termination
Date: Sun, 3 Jan 2016 09:04:04 -0800
Message-ID: <20160103090404.054e724b@xeon-e3>
References: <1451837384-2177-1-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35529 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbcACRDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 12:03:55 -0500
Received: by mail-pa0-f44.google.com with SMTP id ho8so915618pac.2
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2016 09:03:55 -0800 (PST)
In-Reply-To: <1451837384-2177-1-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  3 Jan 2016 17:09:44 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> This is a followup to a previous commit 61170fd88d264c
> "get rid of unnecessary fgets() buffer size limitation".
> 
> If fgets guarantees buffer will be null terminated in the
> given size, then we can also drop the explicit termination.
> 
> While at it, also add an unrelated FIXME comment about
> potential unlikely long comment handling bug spotted in
> nearby code.
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> ---
>  misc/arpd.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/misc/arpd.c b/misc/arpd.c
> index 6bb9bd1..3be700d 100644
> --- a/misc/arpd.c
> +++ b/misc/arpd.c
> @@ -702,12 +702,16 @@ int main(int argc, char **argv)
>  			goto do_abort;
>  		}
>  
> -		buf[sizeof(buf)-1] = 0;
>  		while (fgets(buf, sizeof(buf), fp)) {
>  			__u8 b1[6];
>  			char ipbuf[128];
>  			char macbuf[128];
>  
> +			/* FIXME: this does not properly handle the case where
> +			 * the comment line is longer than sizeof(buf).
> +			 * Should check if buf contains '\n' or skip upcoming
> +			 * bufs until '\n' is found.
> +			 */
>  			if (buf[0] == '#')
>  				continue;
>  

Rather than adding a big FIXME, please fix the problem.

Easiest fix would be just increase sizeof(buf) to BUFSIZ (4k) which
should fix any rational use of the file.

Other alternatives would be to use fscanf or getline.
