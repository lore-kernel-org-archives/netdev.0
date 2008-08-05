From: "=?ISO-8859-1?Q?Jochen_Vo=DF?=" <jochen.voss@googlemail.com>
Subject: Re: [PATCH 2/4] list.h: add list_cut_position()
Date: Tue, 5 Aug 2008 09:52:22 +0100
Message-ID: <ef1cd66f0808050152g1dd8b96cl2df820607d480f0f@mail.gmail.com>
References: <1217890089-12100-1-git-send-email-lrodriguez@atheros.com>
	 <20080804160011.ec964f1f.randy.dunlap@oracle.com>
	 <20080804231320.GG6447@tesla>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Randy Dunlap" <randy.dunlap@oracle.com>,
	"Luis Rodriguez" <Luis.Rodriguez@atheros.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@venema.h4ckr.net" <ath9k-devel@venema.h4ckr.net>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760647AbYHEI7A@vger.kernel.org>
In-Reply-To: <20080804231320.GG6447@tesla>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

2008/8/5 Luis R. Rodriguez <lrodriguez@atheros.com>:
> +static inline void __list_cut_position(struct list_head *list,
> +               struct list_head *head, struct list_head *entry)
> +{
> +       struct list_head *new_first =
> +               (entry->next != head) ? entry->next : head;

Isn't this just an over-complicated way of writing "new_first = entry->next"?

> +       list->next = head->next;
> +       list->next->prev = list;
> +       list->prev = entry;
> +       entry->next = list;
> +       head->next = new_first;
> +       new_first->prev = head;
> +}
> +
> +/**
> + * list_cut_position - cut a list into two
> + * @list: a new list to add all removed entries
> + * @head: a list with entries
> + * @entry: an entry within head, could be the head itself
> + *     and if so we won't cut the list
> + */

I think it would be helpful if the comment explained what the function
actually does, i.e. that it moves the inital part of 'head' (up to and
including 'entry' from 'head' to 'list'.

> +static inline void list_cut_position(struct list_head *list,
> +               struct list_head *head, struct list_head *entry)
> +{
> +       BUG_ON(list_empty(head));
> +       if (list_is_singular(head))
> +               BUG_ON(head->next != entry && head != entry);

No other list function in "list.h" has BUG_ONs.  Why this one?

> +       if (entry == head)
> +               INIT_LIST_HEAD(list);

If there was data in 'list' before the call, it will be lost now.  Is
this intended behaviour?

> +       else
> +               __list_cut_position(list, head, entry);
> +}
> +

I hope this helps,
Jochen
-- 
http://seehuhn.de/
