From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] mlx4: set csum_complete_sw bit when fixing complete csum
Date: Mon, 27 Jun 2016 14:49:58 -0700
Message-ID: <CAM_iQpU2RjMi9byMfk-CyaXuRwVVacqQfeOSTa4xmiqhnuZ_Kw@mail.gmail.com>
References: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com>
 <CAM_iQpUBQqV3oC7=WqyNtu58HmbJbV29yz6_r_ib6XqWpw7VGg@mail.gmail.com> <CALx6S37LNGZEc+zPOu4fnYEYZ36dMKiimsz2XhgFs_rMOyFigg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Carol L Soto <clsoto@us.ibm.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33319 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbcF0VuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 17:50:19 -0400
Received: by mail-qk0-f181.google.com with SMTP id q79so84795471qke.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 14:50:18 -0700 (PDT)
In-Reply-To: <CALx6S37LNGZEc+zPOu4fnYEYZ36dMKiimsz2XhgFs_rMOyFigg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 2:47 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Jun 27, 2016 at 2:44 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Mon, Jun 27, 2016 at 2:08 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Mon, Jun 27, 2016 at 9:22 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>> The stack doesn't trust the complete csum by hardware
>>>> even when it is correct.
>>>
>>> Can you explain that a little further?
>>
>> Sure, here is the code in __skb_checksum_complete():
>>
>>         /* skb->csum holds pseudo checksum */
>>         sum = csum_fold(csum_add(skb->csum, csum));
>>         if (likely(!sum)) {
>>                 if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) &&
>>                     !skb->csum_complete_sw)
>>                         netdev_rx_csum_fault(skb->dev);
>>         }
>>
>> So when sum == 0, it means the checksum is correct. And
>> we already set ->ip_summed to CHECKSUM_COMPLETE
>> after check_csum(), and ->csum_complete_sw is initialized
>> to 0 when we allocate the skb. This is why we trigger
>> netdev_rx_csum_fault().
>>
> Yes, but this also means that the driver gave the stack a checksum
> complete value that was incorrect. That's an error.

That is the whole purpose of commit f8c6455bb04b944edb69e,
isn't it?
