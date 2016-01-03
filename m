From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH iproute2 v2 2/2] arpd: fix parsing of unlikely long
 comments
Date: Sun, 3 Jan 2016 19:44:29 +0100
Message-ID: <20160103184429.GA2713@fatal.se>
References: <20160103090404.054e724b@xeon-e3>
 <1451846374-2665-1-git-send-email-andreas@fatal.se>
 <1451846374-2665-2-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-83-233-174-181.cust.bredband2.com ([83.233.174.181]:40684
	"EHLO pi.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbcACSoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 13:44:30 -0500
Content-Disposition: inline
In-Reply-To: <1451846374-2665-2-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen Hemminger.

Please beware that this has been compile-tested only.
Submitting it like this was what I was trying to avoid
by just throwing in a FIXME comment in the initial submission.
Sorry in advance if I managed to screw something up, but
hopefully I didn't...

Regards,
Andreas Henriksson

On Sun, Jan 03, 2016 at 07:39:33PM +0100, Andreas Henriksson wrote:
> In case the commented out line was longer than the buffer size,
> the remaining part was previously not properly skipped.
> 
> With this fix we should now continue ignoring lines starting with #
> until we find a newline character.
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> ---
>  misc/arpd.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/misc/arpd.c b/misc/arpd.c
> index 700dc50..a4f0f0d 100644
> --- a/misc/arpd.c
> +++ b/misc/arpd.c
> @@ -691,6 +691,7 @@ int main(int argc, char **argv)
>  		FILE *fp;
>  		struct dbkey k;
>  		DBT dbkey, dbdat;
> +		int skip_until_eol = 0;
>  
>  		dbkey.data = &k;
>  		dbkey.size = sizeof(k);
> @@ -707,8 +708,19 @@ int main(int argc, char **argv)
>  			char ipbuf[128];
>  			char macbuf[128];
>  
> -			if (buf[0] == '#')
> +			/* skip remaining part of commented outline. */
> +			if (skip_until_eol) {
> +				if (strrchr(buf, '\n') != NULL)
> +					skip_until_eol = 0;
>  				continue;
> +			}
> +
> +			/* skip (beginning of) commented out line. */
> +			if (buf[0] == '#') {
> +				if (strrchr(buf, '\n') == NULL)
> +					skip_until_eol = 1;
> +				continue;
> +			}
>  
>  			if (sscanf(buf, "%u%s%s", &k.iface, ipbuf, macbuf) != 3) {
>  				fprintf(stderr, "Wrong format of input file \"%s\"\n", do_load);
> -- 
> 2.1.4
> 
