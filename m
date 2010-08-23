From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability support
Date: Mon, 23 Aug 2010 21:37:35 +0800
Message-ID: <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	linux-security-module@vger.kernel.org
To: luciano.coelho@nokia.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 23, 2010 at 8:50 PM,  <luciano.coelho@nokia.com> wrote:
> From: Luciano Coelho <luciano.coelho@nokia.com>
>
> Add a module parameter that allows the required security capability t=
o
> change the conditions from userspace to be specified. =A0By default t=
he
> module will require the CAP_NET_ADMIN capability.
>
> Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
> ---
> =A0net/netfilter/xt_condition.c | =A0 10 ++++++++++
> =A01 files changed, 10 insertions(+), 0 deletions(-)
>
> diff --git a/net/netfilter/xt_condition.c b/net/netfilter/xt_conditio=
n.c
> index 06205aa..fd279e5 100644
> --- a/net/netfilter/xt_condition.c
> +++ b/net/netfilter/xt_condition.c
> @@ -29,11 +29,13 @@
> =A0#include <linux/netfilter/xt_condition.h>
> =A0#include <net/netns/generic.h>
> =A0#include <asm/uaccess.h>
> +#include <linux/capability.h>
>
> =A0/* Defaults, these can be overridden on the module command-line. *=
/
> =A0static unsigned int condition_list_perms =3D S_IRUGO | S_IWUSR;
> =A0static unsigned int condition_uid_perms =3D 0;
> =A0static unsigned int condition_gid_perms =3D 0;
> +static unsigned int condition_capabilities =3D CAP_NET_ADMIN;
>
> =A0MODULE_AUTHOR("Stephane Ouellette <ouellettes@videotron.ca>");
> =A0MODULE_AUTHOR("Massimiliano Hofer <max@nucleus.it>");
> @@ -47,6 +49,8 @@ module_param(condition_uid_perms, uint, S_IRUSR | S=
_IWUSR);
> =A0MODULE_PARM_DESC(condition_uid_perms, "default user owner of /proc=
/net/nf_condition/* files");
> =A0module_param(condition_gid_perms, uint, S_IRUSR | S_IWUSR);
> =A0MODULE_PARM_DESC(condition_gid_perms, "default group owner of /pro=
c/net/nf_condition/* files");
> +module_param(condition_capabilities, uint, CAP_NET_ADMIN);
> +MODULE_PARM_DESC(condition_capabilities, "default capabilities requi=
red to change /proc/net/nf_condition/* files");

It is strange that we set security policy in this way. Maybe the
permission of the proc file is enough in this case.

> =A0MODULE_ALIAS("ipt_condition");
> =A0MODULE_ALIAS("ip6t_condition");
>
> @@ -88,6 +92,12 @@ static int condition_proc_write(struct file *file,=
 const char __user *input,
> =A0 =A0 =A0 =A0char buf[sizeof("+037777777777")];
> =A0 =A0 =A0 =A0unsigned long long value;
>
> + =A0 =A0 =A0 if (!capable(condition_capabilities)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("not enough capabilities (requ=
ires %0X)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 condition_capabilities)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0if (length =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> --
> 1.7.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
