From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [iproute2 PATCH v2 1/1] tc simple action update and breakage
Date: Tue, 24 May 2016 00:39:19 +0200
Message-ID: <57438697.8030801@iogearbox.net>
References: <1462719726-7598-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38072 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbcEWWjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 18:39:23 -0400
In-Reply-To: <1462719726-7598-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2016 05:02 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Brings it closer to more serious actions (adding branching
> and allowing for late binding)
>
> Unfortunately this breaks old syntax of the simple action.
> But because simple is a pedagogical example unlikely to be used
> in production environments (i.e its role is to serve as an example
> on how to write actions), then this is ok.
>
> New syntax for simple has new keyword "sdata". Example usage is:
>
> sudo tc actions add action simple sdata "foobar" index 1
> or
> tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
> match ip dst 17.0.0.1/32 flowid 1:10 action simple sdata "foobar"
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
[...]

>   static void usage(void)
> @@ -99,56 +100,85 @@ parse_simple(struct action_util *a, int *argc_p,=
 char ***argv_p, int tca_id,
>   	struct tc_defact sel =3D {};
>   	int argc =3D *argc_p;
>   	char **argv =3D *argv_p;
> -	int ok =3D 0;
> +	int ok =3D 0, maybe_bind =3D 0;
>   	struct rtattr *tail;
>   	char *simpdata =3D NULL;
>
[...]

>   	if (argc) {
>   		if (matches(*argv, "index") =3D=3D 0) {
>   			NEXT_ARG();
>   			if (get_u32(&sel.index, *argv, 10)) {
> -				fprintf(stderr, "simple: Illegal \"index\"\n");
> +				fprintf(stderr, "simple: Illegal \"index\"\n",
> +					*argv);
>   				return -1;
>   			}

Btw, this causes:

m_simple.c: In function =91parse_simple=92:
m_simple.c:154:6: warning: too many arguments for format [-Wformat-extr=
a-args]
       *argv);
       ^
m_simple.c:103:14: warning: unused variable =91maybe_bind=92 [-Wunused-=
variable]
   int ok =3D 0, maybe_bind =3D 0;
               ^
