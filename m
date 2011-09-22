From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v3 1/7] Basic kernel memory functionality for the Memory Controller
Date: Wed, 21 Sep 2011 22:58:04 -0700
Message-ID: <CAHH2K0YNUNAr7SVkPYKCsU_9Cp4v=AhQ0RVBgmwNNRHJWFgUBA@mail.gmail.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org,
	lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com,
	ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-mm@kvack.org, kirill@shutemov.name
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:1553 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab1IVF62 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 01:58:28 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p8M5wP8W010026
	for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 22:58:25 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by wpaz37.hot.corp.google.com with ESMTP id p8M5w5LB031092
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 22:58:24 -0700
Received: by qwj9 with SMTP id 9so4940325qwj.9
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 22:58:24 -0700 (PDT)
In-Reply-To: <1316393805-3005-2-git-send-email-glommer@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa <glommer@parallels.com> =
wrote:
> @@ -270,6 +274,10 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0struct res_counter memsw;
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* the counter to account for kmem usage.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct res_counter kmem;
> + =A0 =A0 =A0 /*

I don't see this charged, is this used in a later patch in this series?

> @@ -5665,3 +5754,17 @@ static int __init enable_swap_account(char *s)
> =A0__setup("swapaccount=3D", enable_swap_account);
>
> =A0#endif
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +static int __init disable_kmem_account(char *s)

Minor nit.  To be consistent with the other memcg __setup options, I
think this should be renamed to enable_kmem_account().

> +{
> + =A0 =A0 =A0 /* consider enabled if no parameter or 1 is given */
> + =A0 =A0 =A0 if (!strcmp(s, "1"))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_kmem_account =3D 1;
> + =A0 =A0 =A0 else if (!strcmp(s, "0"))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_kmem_account =3D 0;
> + =A0 =A0 =A0 return 1;
> +}
> +__setup("kmemaccount=3D", disable_kmem_account);
> +
> +#endif
