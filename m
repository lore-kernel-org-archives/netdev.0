From: "Guzman Mosqueda, Jose R" <jose.r.guzman.mosqueda@intel.com>
Subject: RE: [PATCH iproute2] ss: Fix allocation of cong control alg name
Date: Fri, 29 May 2015 16:17:49 +0000
Message-ID: <F15B4449A1150D418551CFE4D16B783B86469FBC@FMSMSX102.amr.corp.intel.com>
References: <1432895400-12266-1-git-send-email-vadim4j@gmail.com>
 <556848F4.6080003@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:33571 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754889AbbE2QR7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 12:17:59 -0400
In-Reply-To: <556848F4.6080003@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel and Vadim

Thanks for your prompt response and for the patch.

Also, what about the other one? Do you think it is an issue or not?

" File: tc/tc_util.c
=46unction: void print_rate(char *buf, int len, __u64 rate)
Line: ~264

In the case that user inputs a high value for rate, the "for" loop will=
 exit in the condition meaning that variable "i" get the value of 5 whi=
ch will be an invalid index for the "units" array due to that array has=
 only 5 elements."

I know a very high value is invalid but in the case that it comes direc=
tly from user, it could cause and issue, what do you think?

Thanks,
-Jos=E9 R.




-----Original Message-----
=46rom: Daniel Borkmann [mailto:daniel@iogearbox.net]=20
Sent: Friday, May 29, 2015 6:10 AM
To: Vadim Kochan
Cc: netdev@vger.kernel.org; Guzman Mosqueda, Jose R
Subject: Re: [PATCH iproute2] ss: Fix allocation of cong control alg na=
me

Hi Vadim,

On 05/29/2015 12:30 PM, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
>
> Use strdup instead of malloc, and get rid of bad strcpy.
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Please also Cc the reporter (done here), and add a:

=46ixes: 8250bc9ff4e5 ("ss: Unify inet sockets output")
Reported-by: Jose R. Guzman Mosqueda <jose.r.guzman.mosqueda@intel.com>

=46ixes tag is _very useful_ for distros to easily identify if addition=
al follow-up commits would be needed when backporting the original chan=
ge.
Then, this can be easily identified when going through the git log.

> ---
>   misc/ss.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/misc/ss.c b/misc/ss.c
> index 347e3a1..a719466 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -1908,8 +1908,7 @@ static void tcp_show_info(const struct nlmsghdr=
=20
> *nlh, struct inet_diag_msg *r,
>
>   		if (tb[INET_DIAG_CONG]) {
>   			const char *cong_attr =3D rta_getattr_str(tb[INET_DIAG_CONG]);
> -			s.cong_alg =3D malloc(strlen(cong_attr + 1));
> -			strcpy(s.cong_alg, cong_attr);
> +			s.cong_alg =3D strdup(cong_attr);

strdup(3) can still return NULL.

>   		}
>
>   		if (TCPI_HAS_OPT(info, TCPI_OPT_WSCALE)) {
>
