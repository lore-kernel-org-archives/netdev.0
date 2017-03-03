From: Alexander Potapenko <glider@google.com>
Subject: Re: [PATCH] selinux: check for address length in selinux_socket_bind()
Date: Fri, 3 Mar 2017 18:26:25 +0100
Message-ID: <CAG_fn=WHuZX-LitQ3xWxQzpFE2Pkj_CkYaS+3vMhA9B1ztpm_A@mail.gmail.com>
References: <20170303172330.83421-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>, selinux@tycho.nsa.gov
To: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Kees Cook <keescook@chromium.org>,
        Eric Dumazet <edumazet@google.com>,
        Paul Moore <paul@paul-moore.com>, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35336 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752019AbdCCRdZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 12:33:25 -0500
Received: by mail-qk0-f181.google.com with SMTP id v125so7500357qkh.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 09:33:24 -0800 (PST)
In-Reply-To: <20170303172330.83421-1-glider@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 3, 2017 at 6:23 PM, Alexander Potapenko <glider@google.com> wro=
te:
> KMSAN (KernelMemorySanitizer, a new error detection tool) reports use of
> uninitialized memory in packet_bind_spkt():
Should be "in selinux_socket_bind()", will fix in the next patch version.
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> BUG: KMSAN: use of unitialized memory
> inter: 0
> CPU: 3 PID: 1074 Comm: packet2 Tainted: G    B           4.8.0-rc6+ #1916
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2=
011
>  0000000000000000 ffff8800882ffb08 ffffffff825759c8 ffff8800882ffa48
>  ffffffff818bf551 ffffffff85bab870 0000000000000092 ffffffff85bab550
>  0000000000000000 0000000000000092 00000000bb0009bb 0000000000000002
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff825759c8>] dump_stack+0x238/0x290 lib/dump_stack.c:51
>  [<ffffffff818bdee6>] kmsan_report+0x276/0x2e0 mm/kmsan/kmsan.c:1008
>  [<ffffffff818bf0fb>] __msan_warning+0x5b/0xb0 mm/kmsan/kmsan_instr.c:424
>  [<ffffffff822dae71>] selinux_socket_bind+0xf41/0x1080 security/selinux/h=
ooks.c:4288
>  [<ffffffff8229357c>] security_socket_bind+0x1ec/0x240 security/security.=
c:1240
>  [<ffffffff84265d98>] SYSC_bind+0x358/0x5f0 net/socket.c:1366
>  [<ffffffff84265a22>] SyS_bind+0x82/0xa0 net/socket.c:1356
>  [<ffffffff81005678>] do_syscall_64+0x58/0x70 arch/x86/entry/common.c:292
>  [<ffffffff8518217c>] entry_SYSCALL64_slow_path+0x25/0x25 arch/x86/entry/=
entry_64.o:?
> chained origin: 00000000ba6009bb
>  [<ffffffff810bb7a7>] save_stack_trace+0x27/0x50 arch/x86/kernel/stacktra=
ce.c:67
>  [<     inline     >] kmsan_save_stack_with_flags mm/kmsan/kmsan.c:322
>  [<     inline     >] kmsan_save_stack mm/kmsan/kmsan.c:337
>  [<ffffffff818bd2b8>] kmsan_internal_chain_origin+0x118/0x1e0 mm/kmsan/km=
san.c:530
>  [<ffffffff818bf033>] __msan_set_alloca_origin4+0xc3/0x130 mm/kmsan/kmsan=
_instr.c:380
>  [<ffffffff84265b69>] SYSC_bind+0x129/0x5f0 net/socket.c:1356
>  [<ffffffff84265a22>] SyS_bind+0x82/0xa0 net/socket.c:1356
>  [<ffffffff81005678>] do_syscall_64+0x58/0x70 arch/x86/entry/common.c:292
>  [<ffffffff8518217c>] return_from_SYSCALL_64+0x0/0x6a arch/x86/entry/entr=
y_64.o:?
> origin description: ----address@SYSC_bind (origin=3D00000000b8c00900)
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> (the line numbers are relative to 4.8-rc6, but the bug persists upstream)
>
> , when I run the following program as root:
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>   #include <string.h>
>   #include <sys/socket.h>
>   #include <netinet/in.h>
>
>   int main(int argc, char *argv[]) {
>     struct sockaddr addr;
>     int size =3D 0;
>     if (argc > 1) {
>       size =3D atoi(argv[1]);
>     }
>     memset(&addr, 0, sizeof(addr));
>     int fd =3D socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP);
>     bind(fd, &addr, size);
>     return 0;
>   }
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
>
> (for different values of |size| other error reports are printed).
>
> This happens because bind() unconditionally copies |size| bytes of
> |addr| to the kernel, leaving the rest uninitialized. Then
> security_socket_bind() reads the IP address bytes, including the
> uninitialized ones, to determine the port, or e.g. pass them further to
> sel_netnode_find(), which uses them to calculate a hash.
>
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  security/selinux/hooks.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 0a4b4b040e0a..eba54489b11b 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -4351,10 +4351,19 @@ static int selinux_socket_bind(struct socket *soc=
k, struct sockaddr *address, in
>                 u32 sid, node_perm;
>
>                 if (family =3D=3D PF_INET) {
> +                       if (addrlen !=3D sizeof(struct sockaddr_in)) {
> +                               err =3D -EINVAL;
> +                               goto out;
> +                       }
>                         addr4 =3D (struct sockaddr_in *)address;
>                         snum =3D ntohs(addr4->sin_port);
>                         addrp =3D (char *)&addr4->sin_addr.s_addr;
> +
>                 } else {
> +                       if (addrlen !=3D sizeof(struct sockaddr_in6)) {
> +                               err =3D -EINVAL;
> +                               goto out;
> +                       }
>                         addr6 =3D (struct sockaddr_in6 *)address;
>                         snum =3D ntohs(addr6->sin6_port);
>                         addrp =3D (char *)&addr6->sin6_addr.s6_addr;
> --
> 2.12.0.rc1.440.g5b76565f74-goog
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
