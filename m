From: Rune Magnussen <rum@bankdata.dk>
Subject: Re: [BISECTED] Linux 3.2: Networking out of LAN does not work
Date: Thu, 26 Jan 2012 08:14:46 +0100
Message-ID: <OF554BAA9F.77CBC8B6-ONC1257991.00272C08-C1257991.0027CE20@bdpnet.dk>
References: <1327489531.2425.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.bankdata.dk ([194.239.188.13]:37287 "HELO mx4.bankdata.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751010Ab2AZHO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 02:14:59 -0500
In-Reply-To: <1327489531.2425.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> 
Sendt af: netdev-owner@vger.kernel.org
25-01-2012 12:06
58efa841-5316-9749-1633-85629e363385

Til
Rune Magnussen <rum@bankdata.dk>, David Miller <davem@davemloft.net>
cc
netdev@vger.kernel.org, Mihai Maruseac <mihai.maruseac@gmail.com>
Emne
Re: [BISECTED] Linux 3.2: Networking out of LAN does not work







> OK please test the following patch.

> [PATCH] net: use index hash for /proc/net/dev

> Commit f04565ddf52e (dev: use name hash for dev_seq_ops) added a
> regression for legacy apps expecting to find devices in a particular
> order.

> Instead of using name hash, we can use dev_index_head hash, based on
> device index, to not change device ordering.

> Name hash order is not particularly useful, while index ordering is
> meaningful on machines where no more than 256 devices are ever created.

> "cat /proc/net/dev" and "ip link" will output devices in same order.

> Reported-by: Rune Magnussen <rum@bankdata.dk>
> Bisected-by: Rune Magnussen <rum@bankdata.dk>
> Cc: Mihai Maruseac <mihai.maruseac@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> net/core/dev.c |    4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 115dee1..c58dba3 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4052,9 +4052,9 @@ static inline struct net_device 
*dev_from_same_bucket(struct seq_file *seq)
> 
>                bucket = get_bucket(state->pos);
>                offset = get_offset(state->pos);
> -              h = &net->dev_name_head[bucket];
> +              h = dev_index_hash(net, bucket);
>                count = 0;
> -              hlist_for_each_entry_rcu(dev, p, h, name_hlist) {
> +              hlist_for_each_entry_rcu(dev, p, h, index_hlist) {
>                                if (count++ == offset) {
>                                                state->pos = 
set_bucket_offset(bucket, count);
>                                                return dev;
>

The patch works for me. I applied it on top of v3.2.1 and it fixed my 
problem.
I have not tested it on other computers yet.

Greetings Rune
