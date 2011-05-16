From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: several packets in a single buffer in Rx
Date: Mon, 16 May 2011 15:13:38 +0200
Message-ID: <BANLkTi=xJbL-26Hzg0Pp5zKPUi35bV6VmA@mail.gmail.com>
References: <BANLkTimkgtQL1A2A3iAP-UYK2KdDvPmY3Q@mail.gmail.com>
 <BANLkTinb3kaK7_b=47AL+Mb6Zmt9twEM9g@mail.gmail.com> <BANLkTi=aBLPX7OMKi=sMhT81x-2f6Ci6sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"Guy, Wey-Yi" <wey-yi.w.guy@intel.com>, guy.cohen@intel.com
To: Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:53309 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab1EPNN7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 09:13:59 -0400
In-Reply-To: <BANLkTi=aBLPX7OMKi=sMhT81x-2f6Ci6sQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 16 maja 2011 14:59 u=BFytkownik Emmanuel Grumbach
<egrumbach@gmail.com> napisa=B3:
> 2011/5/16 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
>> 2011/5/16 Emmanuel Grumbach <egrumbach@gmail.com>:
>>> I would like to be able to deliver the same page several times to t=
he
>>> stack without having the stack consume it before the last time I
>>> deliver it.
>>> Of course I would like to avoid cloning it.
>>
>> Just do get_page() on the page having another packet in it before
>> passing skb up.
>>
>
> I can see the path:
> __kfree_skb -> skb_release_all -> skb_release_data -> put_page
> put_page will free the page iff the _count variable reaches 0. Of cou=
rse,
> _count is incremented by get_page.
>
> I will give it try.
>
> I understand that this will work regardless the order given to
> alloc_pages right ?

Yes. Remember that if you put a lot of packets in a big-order page
then the memory will be freed only after all packets are freed.

Best Regards,
Micha=B3 Miros=B3aw
