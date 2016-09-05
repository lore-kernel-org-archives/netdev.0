From: Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
Subject: Re: [PATCH] RDS: Simplify code
Date: Mon, 5 Sep 2016 06:38:21 +0200
Message-ID: <73fc4be8-2530-b9ab-945b-887db6dca2a6@wanadoo.fr>
References: <1472880809-29216-1-git-send-email-christophe.jaillet@wanadoo.fr>
 <20160904122049.GQ21847@leon.nu>
 <befa1a39-cfc5-721f-e39a-369436237b1c@wanadoo.fr>
 <20160904182354.GR21847@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160904182354.GR21847-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 04/09/2016 à 20:23, Leon Romanovsky a écrit :
> On Sun, Sep 04, 2016 at 05:57:20PM +0200, Christophe JAILLET wrote:
>> Le 04/09/2016 à 14:20, Leon Romanovsky a écrit :
>>> On Sat, Sep 03, 2016 at 07:33:29AM +0200, Christophe JAILLET wrote:
>>>> Calling 'list_splice' followed by 'INIT_LIST_HEAD' is equivalent to
>>>> 'list_splice_init'.
>>> It is not 100% accurate
>>>
>>> list_splice(y, z)
>>> INIT_LIST_HEAD(y)
>>>
>>> ==>
>>>
>>> if (!list_empty(y))
>>>       __list_splice(y, z, z>next);
>>> INIT_LIST_HEAD(y)
>>>
>>> and not
>>>
>>> if (!list_empty(y)) {
>>>       __list_splice(y, z, z>next);
>>>       INIT_LIST_HEAD(y)
>>> }
>>>
>>> as list_splice_init will do.
>>>
>> You are right but if you dig further you will see that calling
>> INIT_LIST_HEAD on an empty list is a no-op (AFAIK).
>> And if this list was not already correctly initialized, then you would have
>> some other troubles.
> Thank you for the suggestion,
> It looks like the code after that can be skipped in case of loop_conns
> list is empty, the tmp_list will be empty too.
>
> 174         list_for_each_entry_safe(lc, _lc, &tmp_list, loop_node) {
> 175                 WARN_ON(lc->conn->c_passive);
> 176                 rds_conn_destroy(lc->conn);
> 177         }
Yes, but this would require some more code and test. This function 
doesn't seem to be in a hot path, so I'm not sure that the added 
complexity would worth it.
It would require a new 'list_empty()' test and some code rearrangement.

I suppose that testing for emptiness at the beginning or going through a 
list_for_each_entry_safe on a empty list (which will exit immediately 
and do nothing) is more or less the same in term of speed. So keep the 
code simple and readable.

CJ


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
