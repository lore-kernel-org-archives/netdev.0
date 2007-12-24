From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2 action ipt + iptables 1.4.0
Date: Mon, 24 Dec 2007 10:25:32 -0500
Message-ID: <1198509932.9642.75.camel@localhost>
References: <20071224151147.M93927@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:62137 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbXLXPZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 10:25:41 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2744668wah.23
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 07:25:40 -0800 (PST)
In-Reply-To: <20071224151147.M93927@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys,

Looks reasonable to check for libxt as well. 
Please add a signed-off and append mine as well then send to Stephen.

BTW, I just finished compiling iptables 1.4.0 and _it is_ backward
compatible - you just have to point to the correct 
environment variable IPTABLES_LIB_DIR; it seems to work.
In any case, your patch is better.

cheers,
jamal

On Mon, 2007-24-12 at 17:11 +0200, Denys Fedoryshchenko wrote:
> Hi again :-)
> 
> Happy holidays :-)
> 
> It seems there is serious break in compatibility, but can be fixed by ugly
> way. Maybe just to add patch below, and to search libipt AND libxt (for my
> case i just edit and change libipt to libxt, but it can be handled in more
> smart way.
> After i apply all this - it seems working fine.
> 
> iff -Naur iproute2-git/tc/m_ipt.c iproute2-new/tc/m_ipt.c
> --- iproute2-git/tc/m_ipt.c     2007-12-24 16:59:19.000000000 +0200
> +++ iproute2-new/tc/m_ipt.c     2007-12-24 17:07:11.000000000 +0200
> @@ -69,6 +69,27 @@
>  }
> 
>  void
> +xtables_register_target(struct iptables_target *me)
> +{
> +/*      fprintf(stderr, "\nDummy register_target %s \n", me->name);
> +*/
> +       me->next = t_list;
> +       t_list = me;
> +
> +}
> +
> +
> +void
> +xtables_register_match(struct iptables_target *me)
> +{
> +/*      fprintf(stderr, "\nDummy register_target %s \n", me->name);
> +*/
> +       me->next = t_list;
> +       t_list = me;
> +
> +}
> +
> +void
>  exit_tryhelp(int status)
>  {
>         fprintf(stderr, "Try `%s -h' or '%s --help' for more information.\n",
> 
> There is trivial patch also, for bug (IMHO bug) in searching lowercased
> library. If patch not applied - second time it will try to open lib_dir by
> dlopen:-)
> 
> --- iproute2-git/tc/m_ipt.c     2007-12-24 16:59:19.000000000 +0200
> +++ iproute2/tc/m_ipt.c 2007-12-24 17:00:41.000000000 +0200
> @@ -251,7 +251,7 @@
>         sprintf(path,  "%s/libipt_%s.so",lib_dir, new_name);
>         handle = dlopen(path, RTLD_LAZY);
>         if (!handle) {
> -               sprintf(path, lib_dir, "/libipt_%s.so", lname);
> +               sprintf(path, "%s/libipt_%s.so", lib_dir , lname);
>                 handle = dlopen(path, RTLD_LAZY);
>                 if (!handle) {
>                         fputs(dlerror(), stderr);
> 
> Sorry for probably bad style/code, i am not programmer at all.
> 
> 
> --
> Denys Fedoryshchenko
> Technical Manager
> Virtual ISP S.A.L.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

