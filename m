From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Problem: BUG_ON hit in ppp_pernet() when re-connect after
 changing shared key on LAC
Date: Tue, 5 Jul 2016 19:02:03 -0700
Message-ID: <CAM_iQpWTjnFZS6LgW8CBJ_hPdmu+yTgFycfo42VJ32u4onTxBQ@mail.gmail.com>
References: <7fabf4defe2f468bbcc829247de956c0@svr-chch-ex1.atlnz.lc>
 <CAM_iQpVyNghNJHES5-npZgYGFXps0-XTwJyJ-9pLDAuYJ_syWw@mail.gmail.com>
 <CAM_iQpUEKrcuQvcXO_Rembgk_ZKc-v9Pe2ZEuZ5W_QxdcYDDNQ@mail.gmail.com> <6e0b17d147054867ac0f80978ccf91b2@svr-chch-ex1.atlnz.lc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-ppp@vger.kernel.org" <linux-ppp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"g.nault@alphalink.fr" <g.nault@alphalink.fr>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <6e0b17d147054867ac0f80978ccf91b2@svr-chch-ex1.atlnz.lc>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 5, 2016 at 5:05 PM, Matt Bennett
<Matt.Bennett@alliedtelesis.co.nz> wrote:
> On 07/06/2016 08:37 AM, Cong Wang wrote:
>> On Tue, Jul 5, 2016 at 10:59 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> On Mon, Jul 4, 2016 at 7:50 PM, Matt Bennett
>>> <Matt.Bennett@alliedtelesis.co.nz> wrote:
>>>> Using printk I have confirmed that ppp_pernet() is called from
>>>> ppp_connect_channel() when the BUG occurs (i.e. pch->chan_net is NULL).
>>>>
>>>> This behavior appears to have been introduced in commit 1f461dc ("ppp:
>>>> take reference on channels netns").
>>>
>>> We have some race condition here, where a parallel ppp_unregister_channel()
>>> could happen while we are in ppp_connect_channel().
>>>
>>> We need some synchronization for them. I am not sure what is the right lock
>>> here since ppp locking looks crazy.
>>
>> Matt, could you try if the attached patch helps?
>>
>> Thanks!
>>
> I have given that patch a good amount of testing and the BUG_ON() no
> longer is hit. Whether that is the best fix or not I am unsure?

At least my patch makes the net refcnt sync with pch life-time:
we grab a net refcnt when we allocate a pch, and release it when
we are going to destroy a pch. Makes sense to you?

>
> Either way, the following comment in ppp_unregister_channel() seems
> incorrect to me and should probably be deleted unless it is fixed?
>
> /*
>   * This ensures that we have returned from any calls into the
>   * the channel's start_xmit or ioctl routine before we proceed.
>   */

This comment is pretty old, I think it refers to the pch->ppp
check in ppp_connect_channel().

Thanks.
