From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Tue, 22 Nov 2016 14:16:53 +0000
Message-ID: <2eefdb8f-7e87-6009-6e50-c536d4b95dd6@synopsys.com>
References: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
 <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com>
 <20161119135654.GA14079@lnxartpec.se.axis.com>
 <CAJ3bTp7PpUJcz=1JohX=A54UP6vVAafWnB0PGUBSxb5JJiO8Lg@mail.gmail.com>
 <1248f4ce-4859-10e6-fef9-342ea543f8d4@synopsys.com>
 <87c8a24b-0812-7850-cb3f-7be691bab432@st.com>
 <BFA799B0-BB22-4515-AC14-3544A3167B0A@axis.com>
 <ffd3b27c-0bc9-b53b-cc65-c7808595a553@st.com>
 <b126021d-e902-7a53-4d7a-e73ea89a66cf@synopsys.com>
 <A001080B-2DC8-48D9-BD82-8276A9B3BE3D@axis.com>
 <7c7798b5-8cd4-ba99-f526-22d3e06e05db@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Joao Pinto <Joao.Pinto@synopsys.com>,
        Rayagond Kokatanur <rayagond@vayavyalabs.com>,
        Rabin Vincent <rabin@rab.in>, mued dib <kreptor@gmail.com>,
        David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "jiri@mellanox.com" <jiri@mellanox.com>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "CARLOS.PALMINHA@synopsys.com" <CARLOS.PALMINHA@synopsys.com>,
        =?UTF-8?Q?Andreas_Irest=c3=a5l?= <andire@axis.com>,
        "alexandre.torgue@st.com" <alexandre.torgue@st.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Lars Persson <lars.persson@axis.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7c7798b5-8cd4-ba99-f526-22d3e06e05db@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Lars and Peppe,

On 21-11-2016 16:11, Joao Pinto wrote:
> On 21-11-2016 15:43, Lars Persson wrote:
>>
>>
>>> 21 nov. 2016 kl. 16:06 skrev Joao Pinto <Joao.Pinto@synopsys.com>:
>>>
>>>> On 21-11-2016 14:25, Giuseppe CAVALLARO wrote:
>>>>> On 11/21/2016 2:28 PM, Lars Persson wrote:
>>>>>
>>>>>
>>>>>> 21 nov. 2016 kl. 13:53 skrev Giuseppe CAVALLARO <peppe.cavallaro@st.com>:
>>>>>>
>>>>>> Hello Joao
>>>>>>
>>>>>>> On 11/21/2016 1:32 PM, Joao Pinto wrote:
>>>>>>> Hello,
>>>>>>>
>>>>>>>>> On 21-11-2016 05:29, Rayagond Kokatanur wrote:
>>>>>>>>>> On Sat, Nov 19, 2016 at 7:26 PM, Rabin Vincent <rabin@rab.in> wrote:
>>>>>>>>>> On Fri, Nov 18, 2016 at 02:20:27PM +0000, Joao Pinto wrote:
>>>>>>>>>> For now we are interesting in improving the synopsys QoS driver under
>>>>>>>>>> /nect/ethernet/synopsys. For now the driver structure consists of a
>>>>>>>>>> single file
>>>>>>>>>> called dwc_eth_qos.c, containing synopsys ethernet qos common ops and
> 

snip (...)

>>>>>>
>>>>>> Peppe
>>>>>>
>>>>>
>>>>> Hello Joao and others,
>>>>>
>>>
>>> Hi Lars,
>>>
>>>>> As the maintainer of dwc_eth_qos.c I prefer also that we put efforts on the
>>>>> most mature driver, the stmmac.
>>>>>
>>>>> I hope that the code can migrate into an ethernet/synopsys folder to keep the
>>>>> convention of naming the folder after the vendor. This makes it easy for
>>>>> others to find the driver.
>>>>>
>>>>> The dwc_eth_qos.c will eventually be removed and its DT binding interface can
>>>>> then be implemented in the stmmac driver.
>>>
>>> So your ideia is to pick the ethernet/stmmac and rename it to ethernet/synopsys
>>> and try to improve the structure and add the missing QoS features to it?
>>
>> Indeed this is what I prefer.
> 
> Ok, it makes sense.
> Just for curiosity the target setup is the following:
> https://www.youtube.com/watch?v=8V-LB5y2Cos
> but instead of using internal drivers, we desire to use mainline drivers only.
> 
> Thanks!

Regarding this subject, I am thinking of making the following adaption:

a) delete ethernet/synopsys
b) rename ethernet/stmicro/stmmac to ethernet/synopsys

and send you a patch for you to evaluate. Both agree with the approach?
To have a new work base would be important, because I will add to the "new"
structure some missing QoS features like Multichannel support, CBS and later TSN.

Thanks.

> 
>>
>>>
>>>>
>>>> Thanks Lars, I will be happy to support all you on this transition
>>>> and I agree on renaming all.
>>>>
>>>> peppe
>>>>
>>>>
>>>>> - Lars
>>>>>
>>>>>>>
>>>>>>>
>>>>>>>>
>>>>>>>>>
>>>>>>>>> (See http://lists.openwall.net/netdev/2016/02/29/127)
>>>>>>>>>
>>>>>>>>> The former only supports 4.x of the hardware.
>>>>>>>>>
>>>>>>>>> The later supports 4.x and 3.x and already has a platform glue driver
>>>>>>>>> with support for several platforms, a PCI glue driver, and a core driver
>>>>>>>>> with several features not present in the former (for example: TX/RX
>>>>>>>>> interrupt coalescing, EEE, PTP).
>>>>>>>>>
>>>>>>>>> Have you evaluated both drivers?  Why have you decided to work on the
>>>>>>>>> former rather than the latter?
>>>>>>>>
>>>>>>>>
>>>>>>>
>>>>>>> Thanks.
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>
>>>>>
>>>>
>>>
> 
