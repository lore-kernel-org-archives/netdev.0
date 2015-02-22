From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] rhashtable: initialize all rhashtable walker members
Date: Sun, 22 Feb 2015 22:10:09 +0100
Message-ID: <54EA45B1.6080701@iogearbox.net>
References: <1424552111-12077-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>, herbert@gondor.apana.org.au,
	tgraf@suug.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424552111-12077-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/21/2015 09:55 PM, Sasha Levin wrote:
> Commit "rhashtable: Introduce rhashtable_walk_*" forgot to initialize the
> members of struct rhashtable_walker after allocating it, which caused
> an undefined value for 'resize' which is used later on.
>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   lib/rhashtable.c |    3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 9cc4c4a..030484c 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -894,6 +894,9 @@ int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter)
>   	if (!iter->walker)
>   		return -ENOMEM;
>
> +	INIT_LIST_HEAD(&iter->walker->list);
> +	iter->walker->resize = false;
> +

The change seems fine to me, although the INIT_LIST_HEAD() unnecessary
due to the below list_add()?

Anyway, setting resize to false is definitely correct. In practice this
shouldn't cause much issue though as rhashtable_walk_start() would only
reset iterator meta data and set resize to false, but lets fix it.

>   	mutex_lock(&ht->mutex);
>   	list_add(&iter->walker->list, &ht->walkers);
>   	mutex_unlock(&ht->mutex);

Thanks,
Daniel
