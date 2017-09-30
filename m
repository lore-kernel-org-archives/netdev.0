From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 2/5] bpf: Add map_name to bpf_map_info
Date: Fri, 29 Sep 2017 19:07:46 -0700
Message-ID: <20170929190746.322df52d@cakuba>
References: <20170927213756.1254938-1-kafai@fb.com>
        <20170927213756.1254938-3-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:46407 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752639AbdI3CHz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 22:07:55 -0400
In-Reply-To: <20170927213756.1254938-3-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin!

On Wed, 27 Sep 2017 14:37:53 -0700, Martin KaFai Lau wrote:
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 33ccc474fb04..252f4bc9eb25 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -56,6 +56,7 @@ struct bpf_map {
>  	struct work_struct work;
>  	atomic_t usercnt;
>  	struct bpf_map *inner_map_meta;
> +	u8 name[BPF_OBJ_NAME_LEN];

Any reason not to use plain char?  I was looking at adding names to
bpftool and:

map.c: In function =E2=80=98show_map_close=E2=80=99:
map.c:386:13: warning: pointer targets in passing argument 1 of =E2=80=98st=
rlen=E2=80=99 differ in signedness [-Wpointer-sign]
  if (strlen(info->name))
             ^~~~
In file included from map.c:43:0:
/usr/include/string.h:399:15: note: expected =E2=80=98const char *=E2=80=99=
 but argument is of type =E2=80=98__u8 * {aka unsigned char *}=E2=80=99
 extern size_t strlen (const char *__s)
               ^~~~~~
>  };
> =20
>  /* function argument constraints */
