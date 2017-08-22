From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v3 2/5] nstat: Fix for potential NULL pointer
 dereference
Date: Mon, 21 Aug 2017 17:19:45 -0700
Message-ID: <20170821171945.3d1f5a71@xeon-e3>
References: <20170821100308.24854-1-phil@nwl.cc>
        <20170821100308.24854-3-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:37310 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754015AbdHVATr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:19:47 -0400
Received: by mail-pg0-f42.google.com with SMTP id y129so108464110pgy.4
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:19:47 -0700 (PDT)
In-Reply-To: <20170821100308.24854-3-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 12:03:05 +0200
Phil Sutter <phil@nwl.cc> wrote:

> If the string at 'p' contains neither space not newline, 'p' will become
> NULL. Make sure this isn't the case before dereferencing it.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> Changes since v2:
> - Call abort() if 'p' becomes NULL.
> ---
>  misc/nstat.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/misc/nstat.c b/misc/nstat.c
> index a4dd405d43a93..56e9367e99736 100644
> --- a/misc/nstat.c
> +++ b/misc/nstat.c
> @@ -217,6 +217,8 @@ static void load_ugly_table(FILE *fp)
>  			n->next = db;
>  			db = n;
>  			p = next;
> +			if (!p)
> +				abort();
>  		}
>  		n = db;
>  		if (fgets(buf, sizeof(buf), fp) == NULL)

This doesn't do anything better than just dereferencing NULL.
In either case program crashes with no useful information to user.
Not applying this.
