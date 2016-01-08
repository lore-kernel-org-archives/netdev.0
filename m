From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4.4-rc8 6/7] isdn: eicon: diddfunc: Silence frame size
 warning
Date: Sat, 9 Jan 2016 01:20:42 +0300
Message-ID: <5690363A.1050400@cogentembedded.com>
References: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
 <1452256375-24223-7-git-send-email-tim.gardner@canonical.com>
 <5690163B.7050808@cogentembedded.com> <56903296.3090701@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56903296.3090701@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/2016 01:05 AM, Tim Gardner wrote:

>>> From: Tim Gardner <tim.gardner@canonical.com>
>>>
>>> drivers/isdn/hardware/eicon/diddfunc.c: In function 'connect_didd':
>>> drivers/isdn/hardware/eicon/diddfunc.c:77:1: warning: the frame size
>>> of 1152 bytes is larger than 1024 bytes [-Wframe-larger-than=]
>>>
>>> gcc version 5.3.1 20151219 (Ubuntu 5.3.1-4ubuntu1)
>>>
>>> Cc: Armin Schindler <mac@melware.de>
>>> Cc: Karsten Keil <isdn@linux-pingi.de>
>>> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
>>> ---
>>>    drivers/isdn/hardware/eicon/diddfunc.c | 17 +++++++++++++----
>>>    1 file changed, 13 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/drivers/isdn/hardware/eicon/diddfunc.c
>>> b/drivers/isdn/hardware/eicon/diddfunc.c
>>> index b0b23ed..a9feb4f 100644
>>> --- a/drivers/isdn/hardware/eicon/diddfunc.c
>>> +++ b/drivers/isdn/hardware/eicon/diddfunc.c
>>> @@ -52,9 +52,13 @@ static int __init connect_didd(void)
>>>        int x = 0;
>>>        int dadapter = 0;
>>>        IDI_SYNC_REQ req;
>>> -    DESCRIPTOR DIDD_Table[MAX_DESCRIPTORS];
>>> +    DESCRIPTOR *DIDD_Table;
>>>
>>> -    DIVA_DIDD_Read(DIDD_Table, sizeof(DIDD_Table));
>>> +    DIDD_Table = kcalloc(MAX_DESCRIPTORS, sizeof(*DIDD_Table),
>>> GFP_KERNEL);
>>
>>    Previously the array didn't seem to be zeroed, perhaps it's better to
>> use kmalloc_array()?

>> [...]

> The last patch in the series (isdn: eicon: consolidate descriptor
> allocation) consolidates the allocation code into one function. I used
> kmalloc() there because I noticed that diva_didd_read_adapter_array()
> does zero the buffer before using it.
>
> Do you think that is sufficient ?

    If it worked before your patch, yes.

> rtg

MBR, Sergei
