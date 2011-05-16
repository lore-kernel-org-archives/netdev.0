From: Tomas Winkler <tomasw@gmail.com>
Subject: Re: several packets in a single buffer in Rx
Date: Mon, 16 May 2011 23:04:54 +0300
Message-ID: <BANLkTimvCVcQX-7teQgG7EQV9eeLgG3JnQ@mail.gmail.com>
References: <BANLkTimkgtQL1A2A3iAP-UYK2KdDvPmY3Q@mail.gmail.com>
	<BANLkTinb3kaK7_b=47AL+Mb6Zmt9twEM9g@mail.gmail.com>
	<BANLkTi=aBLPX7OMKi=sMhT81x-2f6Ci6sQ@mail.gmail.com>
	<BANLkTi=xJbL-26Hzg0Pp5zKPUi35bV6VmA@mail.gmail.com>
	<BANLkTin_stn+7Ja3hbuaOgtrEVJEoT9Lhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"Guy, Wey-Yi" <wey-yi.w.guy@intel.com>, guy.cohen@intel.com
To: Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:40751 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427Ab1EPUEz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 16:04:55 -0400
In-Reply-To: <BANLkTin_stn+7Ja3hbuaOgtrEVJEoT9Lhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/16 Emmanuel Grumbach <egrumbach@gmail.com>:
> 2011/5/16 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
>> W dniu 16 maja 2011 14:59 u=C5=BCytkownik Emmanuel Grumbach
>> <egrumbach@gmail.com> napisa=C5=82:
>>> 2011/5/16 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
>>>> 2011/5/16 Emmanuel Grumbach <egrumbach@gmail.com>:
>>>>> I would like to be able to deliver the same page several times to=
 the
>>>>> stack without having the stack consume it before the last time I
>>>>> deliver it.
>>>>> Of course I would like to avoid cloning it.
>>>>
>>>> Just do get_page() on the page having another packet in it before
>>>> passing skb up.
>>>>
>>>
>>> I can see the path:
>>> __kfree_skb -> skb_release_all -> skb_release_data -> put_page
>>> put_page will free the page iff the _count variable reaches 0. Of c=
ourse,
>>> _count is incremented by get_page.
>>>
>>> I will give it try.
>>>
>>> I understand that this will work regardless the order given to
>>> alloc_pages right ?
>>
>> Yes. Remember that if you put a lot of packets in a big-order page
>> then the memory will be freed only after all packets are freed.
>
> Sure. Thanks for the help.

How it is ensured that skb manipulation won't corrupt another packet
on the same page?

Thanks
Tomas
