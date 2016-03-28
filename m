From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH] netlabel: fix a problem with netlbl_secattr_catmap_setrng()
Date: Mon, 28 Mar 2016 11:17:28 -0400
Message-ID: <CAHC9VhTV_0tdRgFEcRoF1qjBunjwK6rSp8wpB4Jqjow2ENToCg@mail.gmail.com>
References: <145917783800.9565.7759086668991534988.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: selinux@tycho.nsa.gov, Janak Desai <Janak.Desai@gtri.gatech.edu>,
	Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35431 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbcC1PRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 11:17:46 -0400
Received: by mail-oi0-f41.google.com with SMTP id h6so118178070oia.2
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 08:17:45 -0700 (PDT)
In-Reply-To: <145917783800.9565.7759086668991534988.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 11:10 AM, Paul Moore <pmoore@redhat.com> wrote:
> From: Janak Desai <Janak.Desai@gtri.gatech.edu>
>
> We try to be clever and set large chunks of the bitmap at once, when
> possible; unfortunately we weren't very clever when we wrote the code
> and messed up the if-conditional.  Fix this bug and restore proper
> operation.
>
> Signed-off-by: Janak Desai <Janak.Desai@gtri.gatech.edu>
> Signed-off-by: Paul Moore <paul@paul-moore.com>
> ---
>  net/netlabel/netlabel_kapi.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

DaveM, I'm planning on carrying this in selinux#next unless you really
want to this to go to Linus via the netdev tree.

> diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
> index 28cddc8..1325776 100644
> --- a/net/netlabel/netlabel_kapi.c
> +++ b/net/netlabel/netlabel_kapi.c
> @@ -677,7 +677,7 @@ int netlbl_catmap_setrng(struct netlbl_lsm_catmap **catmap,
>         u32 spot = start;
>
>         while (rc == 0 && spot <= end) {
> -               if (((spot & (BITS_PER_LONG - 1)) != 0) &&
> +               if (((spot & (BITS_PER_LONG - 1)) == 0) &&
>                     ((end - spot) > BITS_PER_LONG)) {
>                         rc = netlbl_catmap_setlong(catmap,
>                                                    spot,
>

-- 
paul moore
www.paul-moore.com
