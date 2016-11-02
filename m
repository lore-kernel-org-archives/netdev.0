From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: [PATCH (net.git) 2/3] stmmac: fix PTP support for GMAC4
Date: Wed, 2 Nov 2016 12:34:19 +0530
Message-ID: <CAJ3bTp4ScTGFKFK+uAFo7ML-yPZLP=hxBCHqxJEnqKzwzVNnqw@mail.gmail.com>
References: <1477464964-5960-1-git-send-email-peppe.cavallaro@st.com>
 <1477464964-5960-3-git-send-email-peppe.cavallaro@st.com> <CAJ3bTp6Q4XF+nogBNf0ZBq73wr=btmNSgrCg=Kv8kvgsVf2jQg@mail.gmail.com>
 <743ffe4a-2c8f-e5f7-f93c-6be16a8a0350@st.com> <CAJ3bTp7YON-+EiXCY+eaBP6NhtGJTngh2pLaKXdp2YPP1i+C6w@mail.gmail.com>
 <a0a8b469-2b5a-3a32-9896-e531ed281a6c@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, alexandre.torgue@st.com,
        Richard Cochran <richardcochran@gmail.com>,
        linux-kernel@vger.kernel.org,
        Seraphin Bonnaffe <seraphin.bonnaffe@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a0a8b469-2b5a-3a32-9896-e531ed281a6c@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 2, 2016 at 12:04 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> Hello Rayagond
>
> if patches are ok, can we consider you Acked-by ?
Yes.

>
> Thx
> Peppe
>
>
> On 10/27/2016 12:51 PM, Rayagond Kokatanur wrote:
>>
>> On Thu, Oct 27, 2016 at 4:02 PM, Giuseppe CAVALLARO
>> <peppe.cavallaro@st.com> wrote:
>>>
>>> Hello Rayagond !
>>>
>>> On 10/27/2016 12:25 PM, Rayagond Kokatanur wrote:
>>>>>
>>>>>
>>>>> +static int dwmac4_wrback_get_rx_timestamp_status(void *desc, u32 ats)
>>>>>>
>>>>>>  {
>>>>>>         struct dma_desc *p = (struct dma_desc *)desc;
>>>>>> +       int ret = -EINVAL;
>>>>>> +
>>>>>> +       /* Get the status from normal w/b descriptor */
>>>>>> +       if (likely(p->des3 & TDES3_RS1V)) {
>>>>>> +               if (likely(p->des1 & RDES1_TIMESTAMP_AVAILABLE)) {
>>>>>> +                       int i = 0;
>>>>>> +
>>>>>> +                       /* Check if timestamp is OK from context
>>>>>> descriptor */
>>>>>> +                       do {
>>>>>> +                               ret = dwmac4_rx_check_timestamp(desc);
>>>>
>>>>
>>>> Here, "desc" is not pointing to next descriptor (ie context
>>>> descriptor). Driver should check the context descriptor.
>>>
>>>
>>>
>>> you are right and this is done by the caller:  stmmac_get_rx_hwtstamp
>>
>>
>> Yes.
>>
>>>
>>> Cheers
>>> peppe
>>>
>>
>>
>>
>



-- 
wwr
Rayagond
