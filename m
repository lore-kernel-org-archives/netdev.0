From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 3/3] netlabel: Less function calls in netlbl_mgmt_add_common()
 after error detection
Date: Sat, 31 Jan 2015 21:40:50 -0500
Message-ID: <CAHC9VhQ5C32zRqG0emVUoMmuvBsV+TXvdNn+54iVyCPBNk9dDQ@mail.gmail.com>
References: <5307CAA2.8060406@users.sourceforge.net>
	<alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
	<530A086E.8010901@users.sourceforge.net>
	<alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
	<530A72AA.3000601@users.sourceforge.net>
	<alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
	<530B5FB6.6010207@users.sourceforge.net>
	<alpine.DEB.2.10.1402241710370.2074@hadrien>
	<530C5E18.1020800@users.sourceforge.net>
	<alpine.DEB.2.10.1402251014170.2080@hadrien>
	<530CD2C4.4050903@users.sourceforge.net>
	<alpine.DEB.2.10.1402251840450.7035@hadrien>
	<530CF8FF.8080600@users.sourceforge.net>
	<alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	<530DD06F.4090703@users.sourceforge.net>
	<alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<54CD45B6.6010703@users.sourceforge.net>
	<54CD4B5F.9010502@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <54CD4B5F.9010502@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 31, 2015 at 4:38 PM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 31 Jan 2015 21:55:48 +0100
>
> The functions "cipso_v4_doi_putdef" and "kfree" could be called in some cases
> by the netlbl_mgmt_add_common() function during error handling even if the
> passed variables contained still a null pointer.
>
> * This implementation detail could be improved by adjustments for jump labels.
>
> * Let us return immediately after the first failed function call according to
>   the current Linux coding style convention.
>
> * Let us delete also an unnecessary check for the variable "entry" there.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/netlabel/netlabel_mgmt.c | 46 ++++++++++++++++++++++----------------------
>  1 file changed, 23 insertions(+), 23 deletions(-)
>
> diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
> index f5807f5..17f1ed5 100644
> --- a/net/netlabel/netlabel_mgmt.c
> +++ b/net/netlabel/netlabel_mgmt.c

...

> @@ -237,15 +235,17 @@ static int netlbl_mgmt_add_common(struct genl_info *info,
>
>         ret_val = netlbl_domhsh_add(entry, audit_info);
>         if (ret_val != 0)
> -               goto add_failure;
> +               goto free_address_map;
>
>         return 0;
>
> -add_failure:
> -       cipso_v4_doi_putdef(cipsov4);
> -       if (entry)
> -               kfree(entry->domain);
> +free_address_map:
>         kfree(addrmap);
> +doi_put_def:
> +       cipso_v4_doi_putdef(cipsov4);
> +free_domain:
> +       kfree(entry->domain);
> +free_entry:
>         kfree(entry);
>         return ret_val;
>  }

It would be nice if you could stick with the goto label naming style
in the rest of the file, e.g.
"add_free_addrmap"/"add_put_doi_def"/"add_free_domain"/"add_free_entry".

-- 
paul moore
www.paul-moore.com
