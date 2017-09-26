From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] lib: fix multiple strlcpy definition
Date: Tue, 26 Sep 2017 17:55:24 +0200
Message-ID: <20170926155524.GA26610@orbyte.nwl.cc>
References: <7f5fee59e46bfd3b4acf8ed9a8fbd8c7b4f1cd70.1506424129.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58022 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966056AbdIZPz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 11:55:27 -0400
Content-Disposition: inline
In-Reply-To: <7f5fee59e46bfd3b4acf8ed9a8fbd8c7b4f1cd70.1506424129.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 02:08:49PM +0300, Baruch Siach wrote:
[...]
> diff --git a/configure b/configure
> index 7be8fb113cc9..787b2e061af9 100755
> --- a/configure
> +++ b/configure
> @@ -326,6 +326,27 @@ EOF
>      rm -f $TMPDIR/dbtest.c $TMPDIR/dbtest
>  }
>  
> +check_strlcpy()
> +{
> +    cat >$TMPDIR/strtest.c <<EOF
> +#include <string.h>
> +int main(int argc, char **argv) {
> +	char dst[10];
> +	strlcpy("test", dst, sizeof(dst));

You swapped source and destination here. It's not important for the
given use-case, but the resulting binary should segfault.

Apart from that, LGTM!

Cheers, Phil
