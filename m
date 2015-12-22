From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath6kl: Use vmalloc to allocate ar->fw for api1 method
Date: Tue, 22 Dec 2015 11:12:16 +0200
Message-ID: <87poxy7spb.fsf@kamboji.qca.qualcomm.com>
References: <1448948470-31111-1-git-send-email-motobud@gmail.com>
	<CAFqt6zaALx895c0BVrMpLdtfgYLz=-mmqaurtD28Nm1Ut2g1Dw@mail.gmail.com>
	<CAP+RiCBK_iEOu27GzqqgG9Pn_MDP1m8JCnSqkGbPMAT7=P9V7g@mail.gmail.com>
	<CAFqt6zZfmue6XVVno2Ho8UfEwz1Z3YxFzbcZ9ZMOn5Fe_zJLmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Brent Taylor <motobud@gmail.com>, <netdev@vger.kernel.org>,
	<ath6kl@lists.infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFqt6zZfmue6XVVno2Ho8UfEwz1Z3YxFzbcZ9ZMOn5Fe_zJLmQ@mail.gmail.com>
	(Souptick Joarder's message of "Tue, 22 Dec 2015 14:35:20 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Souptick Joarder <jrdr.linux@gmail.com> writes:

> Hi Brent,
>
> On Tue, Dec 22, 2015 at 3:23 AM, Brent Taylor <motobud@gmail.com> wrote:
>> On Mon, Dec 21, 2015 at 1:23 PM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
>>> Hi Brent,
>>>
>>> On Tue, Dec 1, 2015 at 11:11 AM, Brent Taylor <motobud@gmail.com> wrote:
>>>
>>>> --- a/drivers/net/wireless/ath/ath6kl/init.c
>>>> +++ b/drivers/net/wireless/ath/ath6kl/init.c
>>>> @@ -673,10 +673,15 @@ static int ath6kl_get_fw(struct ath6kl *ar, const char *filename,
>>>>                 return ret;
>>>>
>>>>         *fw_len = fw_entry->size;
>>>> -       *fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
>>>> +   if (&ar->fw == fw)
>>>> +               *fw = vmalloc(fw_entry->size);
>>>> +   else
>>>> +               *fw = kmalloc(fw_entry->size, GFP_KERNEL)
>>>
>>>           Why vmalloc and kmalloc both are required? can't use either
>>> vmalloc or kmalloc?
>>
>> My original problem was that kmemdup (which uses kmalloc) could not
>> allocate enough memory
>
> If kmemdump ( which uses kmalloc) could not allocate memory then
> using kmalloc again can lead to same problem.
> I guess it will be correct to use
>             *fw = vmalloc(fw_entry->size);
> Correct me if i am wrong.

That sounds best. But remember take into account DMA requirements, IIRC
you cannot DMA from vmalloc memory on all platforms.

-- 
Kalle Valo
