From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] rhashtable: Quick initial growth of tables
Date: Fri, 01 May 2015 14:04:35 +0300
Message-ID: <55435DC3.4060304@cogentembedded.com>
References: <1430434005-6143-1-git-send-email-tgraf@suug.ch> <1430434005-6143-3-git-send-email-tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:33816 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbbEALEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 07:04:38 -0400
Received: by lbcga7 with SMTP id ga7so62944330lbc.1
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 04:04:37 -0700 (PDT)
In-Reply-To: <1430434005-6143-3-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 5/1/2015 1:46 AM, Thomas Graf wrote:

> Grow the table quicker than 2x in the beginning to avoid long chains
> of rehashes. The effect is observable in the self-test where table
> jumps are reduced to a minimum after a lot of entries have been added
> in a short period of time. The iterator is able to get a consistent
> view most of the time.

> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>   lib/rhashtable.c | 37 +++++++++++++++++++++++++++++++++++--
>   1 file changed, 35 insertions(+), 2 deletions(-)

> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 4936fc4..23e7f18 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -271,6 +271,38 @@ static int rhashtable_rehash_table(struct rhashtable *ht)
>   	return rht_dereference(new_tbl->future_tbl, ht) ? -EAGAIN : 0;
>   }
>
> +static int table_growth_log(unsigned int size)
> +{
> +	/*
> +	 * Table growth:
> +	 *     2 ->   64
> +	 *     4 ->  128
> +	 *     8 ->  128
> +	 *    16 ->  256
> +	 *    32 ->  512
> +	 *    64 ->  512
> +	 *   128 -> 1024
> +	 *   256 -> 2048
> +	 *   512 -> 2048
> +	 *  1024 -> 4096
> +	 *  2048 -> 8192
> +	 *  4096 -> 8192
> +	 */
> +	int log = 5 - (ilog2(size) / 3);
> +
> +	return log > 1 ? log : 1;

    max(log, 1)?

[...]

WBR, Sergei
