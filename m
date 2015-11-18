From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [PATCH 2/3] net/ceph: do not define list_entry_next
Date: Wed, 18 Nov 2015 14:13:28 +0100
Message-ID: <CAOi1vP8u-zP6+7sSbAq7Vnutt5o=AKh-MdazC8fz-Vu++gypxw@mail.gmail.com>
References: <1447848780-7672-1-git-send-email-sergey.senozhatsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Yan Zheng <zyan@redhat.com>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <1447848780-7672-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 18, 2015 at 1:13 PM, Sergey Senozhatsky
<sergey.senozhatsky@gmail.com> wrote:
> Cosmetic.
>
> Do not define list_entry_next() and use list_next_entry()
> from list.h.
>
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  net/ceph/messenger.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
> index 9981039..77ccca9 100644
> --- a/net/ceph/messenger.c
> +++ b/net/ceph/messenger.c
> @@ -10,6 +10,7 @@
>  #include <linux/slab.h>
>  #include <linux/socket.h>
>  #include <linux/string.h>
> +#include <linux/list.h>
>  #ifdef CONFIG_BLOCK
>  #include <linux/bio.h>
>  #endif /* CONFIG_BLOCK */
> @@ -23,9 +24,6 @@
>  #include <linux/ceph/pagelist.h>
>  #include <linux/export.h>
>
> -#define list_entry_next(pos, member)                                   \
> -       list_entry(pos->member.next, typeof(*pos), member)
> -
>  /*
>   * Ceph uses the messenger to exchange ceph_msg messages with other
>   * hosts in the system.  The messenger provides ordered and reliable
> @@ -1042,7 +1040,7 @@ static bool ceph_msg_data_pagelist_advance(struct ceph_msg_data_cursor *cursor,
>         /* Move on to the next page */
>
>         BUG_ON(list_is_last(&cursor->page->lru, &pagelist->head));
> -       cursor->page = list_entry_next(cursor->page, lru);
> +       cursor->page = list_next_entry(cursor->page, lru);
>         cursor->last_piece = cursor->resid <= PAGE_SIZE;
>
>         return true;
> @@ -1166,7 +1164,7 @@ static bool ceph_msg_data_advance(struct ceph_msg_data_cursor *cursor,
>         if (!cursor->resid && cursor->total_resid) {
>                 WARN_ON(!cursor->last_piece);
>                 BUG_ON(list_is_last(&cursor->data->links, cursor->data_head));
> -               cursor->data = list_entry_next(cursor->data, links);
> +               cursor->data = list_next_entry(cursor->data, links);
>                 __ceph_msg_data_cursor_init(cursor);
>                 new_piece = true;
>         }

Someone beat you to it ;)

https://github.com/ceph/ceph-client/commit/76b4a27faebb369c1c50df01ef08b614a2854fc5

Thanks,

                Ilya
