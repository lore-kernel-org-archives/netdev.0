From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: several packets in a single buffer in Rx
Date: Mon, 16 May 2011 16:36:45 +0300
Message-ID: <BANLkTin_stn+7Ja3hbuaOgtrEVJEoT9Lhw@mail.gmail.com>
References: <BANLkTimkgtQL1A2A3iAP-UYK2KdDvPmY3Q@mail.gmail.com>
	<BANLkTinb3kaK7_b=47AL+Mb6Zmt9twEM9g@mail.gmail.com>
	<BANLkTi=aBLPX7OMKi=sMhT81x-2f6Ci6sQ@mail.gmail.com>
	<BANLkTi=xJbL-26Hzg0Pp5zKPUi35bV6VmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTi=xJbL-26Hzg0Pp5zKPUi35bV6VmA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2011/5/16 Micha=B3 Miros=B3aw <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> W dniu 16 maja 2011 14:59 u=BFytkownik Emmanuel Grumbach
> <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> napisa=B3:
>> 2011/5/16 Micha=B3 Miros=B3aw <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>>> 2011/5/16 Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
>>>> I would like to be able to deliver the same page several times to =
the
>>>> stack without having the stack consume it before the last time I
>>>> deliver it.
>>>> Of course I would like to avoid cloning it.
>>>
>>> Just do get_page() on the page having another packet in it before
>>> passing skb up.
>>>
>>
>> I can see the path:
>> __kfree_skb -> skb_release_all -> skb_release_data -> put_page
>> put_page will free the page iff the _count variable reaches 0. Of co=
urse,
>> _count is incremented by get_page.
>>
>> I will give it try.
>>
>> I understand that this will work regardless the order given to
>> alloc_pages right ?
>
> Yes. Remember that if you put a lot of packets in a big-order page
> then the memory will be freed only after all packets are freed.

Sure. Thanks for the help.

>
> Best Regards,
> Micha=B3 Miros=B3aw
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
