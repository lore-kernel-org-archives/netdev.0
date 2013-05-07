From: David Herrmann <dh.herrmann@gmail.com>
Subject: Re: [PATCH] Bluetooth: hidp: using strlcpy or strcpy instead of strncpy
Date: Tue, 7 May 2013 21:31:50 +0200
Message-ID: <CANq1E4SmY+CD0uf53_b6GeFkQ-LYnpdxsDGSRMWdn2i1mnb6WQ@mail.gmail.com>
References: <518906A8.7060708@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>, andrei.emeltchenko@intel.com,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:41235 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173Ab3EGTbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 15:31:51 -0400
In-Reply-To: <518906A8.7060708@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Tue, May 7, 2013 at 3:50 PM, Chen Gang <gang.chen@asianux.com> wrote:
>
> For NUL terminated string, need always let it ended by zero.
>
> Since have already called memcpy() to initialize 'ci', so need not
> redundent initializations.
>
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  net/bluetooth/hidp/core.c |   10 +++-------
>  1 files changed, 3 insertions(+), 7 deletions(-)
>
> diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
> index 940f5ac..9a8ae63 100644
> --- a/net/bluetooth/hidp/core.c
> +++ b/net/bluetooth/hidp/core.c
> @@ -76,25 +76,21 @@ static void hidp_copy_session(struct hidp_session *session, struct hidp_conninfo
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
> +                       strcpy(ci->name, "HID Boot Device");

I'd actually prefer strlcpy() here, too (better be safe). Other than
that the patch looks fine.

Reviewed-by: David Herrmann <dh.herrmann@gmail.com>

Regards
David

>         }
>
>         if (session->hid) {
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
