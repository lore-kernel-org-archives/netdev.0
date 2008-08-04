From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 2/4] list.h: add list_cut_position()
Date: Mon, 4 Aug 2008 16:00:11 -0700
Message-ID: <20080804160011.ec964f1f.randy.dunlap@oracle.com>
References: <1217890089-12100-1-git-send-email-lrodriguez@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linville@tuxdriver.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <torvalds@linux-foundation.org>,
	<linux-wireless@vger.kernel.org>, <ath9k-devel@venema.h4ckr.net>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:22145 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbYHDXDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 19:03:42 -0400
In-Reply-To: <1217890089-12100-1-git-send-email-lrodriguez@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Aug 2008 15:48:09 -0700 Luis R. Rodriguez wrote:

> This adds list_cut_position() which lets you cut a list into
> two lists given a pivot in the list.
> 
> Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>
> ---
>  include/linux/list.h |   32 ++++++++++++++++++++++++++++++++
>  1 files changed, 32 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/list.h b/include/linux/list.h
> index 594f67c..2999b0f 100644
> --- a/include/linux/list.h
> +++ b/include/linux/list.h
> @@ -214,6 +214,38 @@ static inline int list_is_singular(const struct list_head *head)
>  	return !list_empty(head) && (head->next == head->prev);
>  }
>  
> +static inline void __list_cut_position(struct list_head *list,
> +		struct list_head *head, struct list_head *entry)
> +{
> +	struct list_head *new_first =
> +		(entry->next != head) ? entry->next : head;
> +	list->next = head->next;
> +	list->next->prev = list;
> +	list->prev = entry;
> +	entry->next = list;
> +	head->next = new_first;
> +	new_first->prev = head;
> +}
> +
> +/**
> + * list_cut_position - cut a list into two
> + * @list: a new list to add all removed entries
> + * @head: a list with entries
> + * @entry: an entry within head, could be the head itself
> + *	and if so we won't won't cut the list

drop one "won't"


> + */
> +static inline void list_cut_position(struct list_head *list,
> +		struct list_head *head, struct list_head *entry)
> +{
> +	BUG_ON(list_empty(head));
> +	if (list_is_singular(head))
> +		BUG_ON(head->next != entry && head != entry);
> +	if (entry == head)
> +		INIT_LIST_HEAD(list);
> +	else
> +		__list_cut_position(list, head, entry);
> +}
> +
>  static inline void __list_splice(const struct list_head *list,
>  				 struct list_head *head)
>  {


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
