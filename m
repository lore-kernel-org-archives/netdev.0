From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v1 1/1] lib/utils: fix get_addr() and
 get_prefix() error messages
Date: Sun, 27 Mar 2016 10:35:06 -0700
Message-ID: <20160327103506.28f3d68e@xeon-e3>
References: <C4896FB061E7DE4AAC93031BDCA044B11A2146FF@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"Szczerbik, PrzemyslawX" <przemyslawx.szczerbik@intel.com>
To: "Varlese, Marco" <marco.varlese@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34607 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbcC0Rev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 13:34:51 -0400
Received: by mail-pa0-f52.google.com with SMTP id fe3so81274960pab.1
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 10:34:51 -0700 (PDT)
In-Reply-To: <C4896FB061E7DE4AAC93031BDCA044B11A2146FF@IRSMSX108.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Mar 2016 13:02:02 +0000
"Varlese, Marco" <marco.varlese@intel.com> wrote:

> An attempt to add invalid address to interface would print "???" string
> instead of the address family name.
> 
> For example:
> $ ip address add 256.10.166.1/24 dev ens8
> Error: ??? prefix is expected rather than "256.10.166.1/24".
> 
> $ ip neighbor add proxy 2001:db8::g dev ens8
> Error: ??? address is expected rather than "2001:db8::g".
> 
> With this patch the output will look like:
> $ ip address add 256.10.166.1/24 dev ens8
> Error: inet prefix is expected rather than "256.10.166.1/24".
> 
> $ ip neighbor add proxy 2001:db8::g dev ens8
> Error: inet6 address is expected rather than "2001:db8::g".
> 
> Signed-off-by: Przemyslaw Szczerbik <przemyslawx.szczerbik@intel.com>
> Signed-off-by: Marco Varlese <marco.varlese@intel.com>
> ---
> lib/utils.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/utils.c b/lib/utils.c
> index fa35f4d..4820de1 100644
> --- a/lib/utils.c
> +++ b/lib/utils.c
> @@ -567,7 +567,7 @@ int get_addr(inet_prefix *dst, const char *arg, int family)
> {
>         if (get_addr_1(dst, arg, family)) {
>                 fprintf(stderr, "Error: %s address is expected rather than \"%s\".\n",
> -                               family_name(family) ,arg);
> +                               family_name(dst->family), arg);
>                 exit(1);
>         }
>         return 0;
> @@ -581,7 +581,7 @@ int get_prefix(inet_prefix *dst, char *arg, int family)
>         }
>         if (get_prefix_1(dst, arg, family)) {
>                 fprintf(stderr, "Error: %s prefix is expected rather than \"%s\".\n",
> -                               family_name(family) ,arg);
> +                               family_name(dst->family), arg);
>                 exit(1);
>         }
>         return 0;

Your patch was corrupted by your email client?

$ patch -p1 <~/Downloads/iproute2-v1-1-1-lib-utils-fix-get_addr-and-get_prefix-error-messages.patch 
patching file lib/utils.c
patch: **** malformed patch at line 6: {
