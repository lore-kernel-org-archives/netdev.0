From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: sel_netif_init: 'err' is used uninitialized (was: Re: selinux: reduce
 the number of calls to synchronize_net() when flushing caches)
Date: Thu, 7 Aug 2014 12:31:15 +0200
Message-ID: <CAMuHMdV4VpaH1nHYO5hr66Xib5o_Pib863JzGRtg2kYcjMp2TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-security-module@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 6, 2014 at 6:27 PM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Gitweb:     http://git.kernel.org/linus/;a=3Dcommit;h=3D615e51fdda6f2=
74e94b1e905fcaf6111e0d9aa20
> Commit:     615e51fdda6f274e94b1e905fcaf6111e0d9aa20
> Parent:     f31e799459659ae88c341aeac16a8a5efb1271d4
> Refname:    refs/heads/master
> Author:     Paul Moore <pmoore@redhat.com>
> AuthorDate: Thu Jun 26 14:33:56 2014 -0400
> Committer:  Paul Moore <pmoore@redhat.com>
> CommitDate: Thu Jun 26 14:33:56 2014 -0400
>
>     selinux: reduce the number of calls to synchronize_net() when flu=
shing caches
>
>     When flushing the AVC, such as during a policy load, the various
>     network caches are also flushed, with each making a call to
>     synchronize_net() which has shown to be expensive in some cases.
>     This patch consolidates the network cache flushes into a single A=
VC
>     callback which only calls synchronize_net() once for each AVC cac=
he
>     flush.

> --- a/security/selinux/netif.c
> +++ b/security/selinux/netif.c

> @@ -291,10 +282,6 @@ static __init int sel_netif_init(void)
>
>         register_netdevice_notifier(&sel_netif_netdev_notifier);
>
> -       err =3D avc_add_callback(sel_netif_avc_callback, AVC_CALLBACK=
_RESET);
> -       if (err)
> -               panic("avc_add_callback() failed, error %d\n", err);
> -
>         return err;

security/selinux/netif.c: In function =E2=80=98sel_netif_init=E2=80=99:
/scratch/geert/linux/linux-m68k/security/selinux/netif.c:285: warning:
=E2=80=98err=E2=80=99 is used uninitialized in this function

Should it just return 0, like before?
Or should it return the return value of register_netdevice_notifier() i=
nstead,
which also returns an error code? Or is that failure non-critical?

>  }

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
