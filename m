From: David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] Bluetooth: hidp: using strlcpy instead of strncpy,
 also beautify code.
Date: Wed, 8 May 2013 17:16:25 +0200
Message-ID: <CANq1E4Q+duvLzwmwN=FHb2AaTQsnSgxRD7T+YsBZLSE-kchR_Q@mail.gmail.com>
References: <518906A8.7060708@asianux.com>
	<CANq1E4SmY+CD0uf53_b6GeFkQ-LYnpdxsDGSRMWdn2i1mnb6WQ@mail.gmail.com>
	<5189A417.503@asianux.com>
	<5189C7C6.8090408@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, andrei.emeltchenko-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5189C7C6.8090408-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Chen

On Wed, May 8, 2013 at 5:34 AM, Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org> wrote:
>
> For NUL terminated string, need always let it ended by zero.
>
> Since have already called memcpy() to initialize 'ci', so need not
> redundent initializations.
>
> Better use ''if(session->hid) {} else if(session->input) {}'' instead
> of ''if(session->hid) {}; if(session->input) {};''

Yep, looks good now.

Reviewed-by: David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks
David

> Signed-off-by: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
> ---
>  net/bluetooth/hidp/core.c |   14 ++++----------
>  1 files changed, 4 insertions(+), 10 deletions(-)
>
> diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
> index 940f5ac..f13a8da 100644
> --- a/net/bluetooth/hidp/core.c
> +++ b/net/bluetooth/hidp/core.c
> @@ -76,25 +76,19 @@ static void hidp_copy_session(struct hidp_session *session, struct hidp_conninfo
>         ci->flags = session->flags;
>         ci->state = BT_CONNECTED;
>
> -       ci->vendor  = 0x0000;
> -       ci->product = 0x0000;
> -       ci->version = 0x0000;
> -
>         if (session->input) {
>                 ci->vendor  = session->input->id.vendor;
>                 ci->product = session->input->id.product;
>                 ci->version = session->input->id.version;
>                 if (session->input->name)
> -                       strncpy(ci->name, session->input->name, 128);
> +                       strlcpy(ci->name, session->input->name, 128);
>                 else
> -                       strncpy(ci->name, "HID Boot Device", 128);
> -       }
> -
> -       if (session->hid) {
> +                       strlcpy(ci->name, "HID Boot Device", 128);
> +       } else if (session->hid) {
>                 ci->vendor  = session->hid->vendor;
>                 ci->product = session->hid->product;
>                 ci->version = session->hid->version;
> -               strncpy(ci->name, session->hid->name, 128);
> +               strlcpy(ci->name, session->hid->name, 128);
>         }
>  }
>
> --
> 1.7.7.6
