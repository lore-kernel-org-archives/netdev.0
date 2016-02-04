From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v2 3/4] lib: add "on"/"off" support to kstrtobool
Date: Fri, 5 Feb 2016 01:00:30 +0200
Message-ID: <CAHp75VfEi4umnfQoDdySn2X6ZEyL1_szzdwvjBgKy=-Uz9KbOg@mail.gmail.com>
References: <1454619643-14444-1-git-send-email-keescook@chromium.org>
	<1454619643-14444-4-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Joe Perches <joe@perches.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Steve French <sfrench@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"x86@kernel.org" <x86@kernel.org>, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, linux-cifs@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454619643-14444-4-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 4, 2016 at 11:00 PM, Kees Cook <keescook@chromium.org> wrote:
> Add support for "on" and "off" when converting to boolean.
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  lib/kstrtox.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
>
> diff --git a/lib/kstrtox.c b/lib/kstrtox.c
> index e18f088704d7..09e83a19a96d 100644
> --- a/lib/kstrtox.c
> +++ b/lib/kstrtox.c
> @@ -347,6 +347,20 @@ int kstrtobool(const char *s, unsigned int base, bool *res)

Forgot update description?

>         case '0':
>                 *res = false;
>                 return 0;
> +       case 'o':
> +       case 'O':
> +               switch (s[1]) {
> +               case 'n':
> +               case 'N':
> +                       *res = true;
> +                       return 0;
> +               case 'f':
> +               case 'F':
> +                       *res = false;
> +                       return 0;
> +               default:
> +                       break;
> +               }
>         default:
>                 break;
>         }
> --
> 2.6.3
>



-- 
With Best Regards,
Andy Shevchenko
