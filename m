From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Wed, 23 Nov 2016 11:43:39 +0000
Message-ID: <f4dd5d22-4467-d046-6b65-2a28f3fc5a7c@synopsys.com>
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
 <2eefdb8f-7e87-6009-6e50-c536d4b95dd6@synopsys.com>
 <c37c47e1-8e21-1b11-ed15-6b899ed1dd03@st.com>
 <7c259adb-5c73-f997-6b96-5be427157b08@synopsys.com>
 <899DC02E-84BB-489E-A1FE-5D8F3BB795B6@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
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
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <899DC02E-84BB-489E-A1FE-5D8F3BB795B6@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23-11-2016 11:41, Lars Persson wrote:
> 
>> 23 nov. 2016 kl. 12:11 skrev Joao Pinto <Joao.Pinto@synopsys.com>:
>>
>> Hi Peppe and Lars,
>>
>>> On 23-11-2016 10:59, Giuseppe CAVALLARO wrote:
>>> Hello Joao, Lars.
>>>
>>>> On 11/22/2016 3:16 PM, Joao Pinto wrote:
>>>>>> Ok, it makes sense.
>>>>>> Just for curiosity the target setup is the following:
>>>>>> https://www.youtube.com/watch?v=8V-LB5y2Cos
>>>>>> but instead of using internal drivers, we desire to use mainline drivers only.
>>>>>>
>>>>>> Thanks!
>>>> Regarding this subject, I am thinking of making the following adaption:
>>>>
>>>> a) delete ethernet/synopsys
>>>> b) rename ethernet/stmicro/stmmac to ethernet/synopsys
>>>>
>>>> and send you a patch for you to evaluate. Both agree with the approach?
>>>> To have a new work base would be important, because I will add to the "new"
>>>> structure some missing QoS features like Multichannel support, CBS and later TSN.
>>>
>>> IMO, we have to agree on a common strategy making the change for
>>> net-next; I imaged the following steps:
>>
>> Yes it makes totally sense.
>>
>>>
>>> - to port missing feature or fixes from ethernet/synopsys
>>>  inside the stmmac taking care about the documentation too.
>>
>> @Lars: You are familiar with the synopsys qos driver. Could you please do this
>> porting. You can also make an analysis of what to port and I can do the porting
>> for you if you don't have the availability for it.
> 
> As my main duty is changing diapers until March next year, please go ahead with this step if you can spend time on it before I am back in office.

Congratulations :)!

> 
> Rabin Vincent can review and test that the port works properly on our Artpec-chips that use dwc_eth_qos.c today.
> 
> The main porting step is to implement the device tree binding in bindings/net/snps,dwc-qos-ethernet.txt. Also our chip has a strict requirement that the phy is enabled when the SWR reset bit is set (it needs a tx clock to complete the reset).
> 
> - Lars

Ok, I will do the task.

@Peppe: Agree with the plan?

> 
>>
>>> - remove ethernet/synopsys
>>> - rename ethernet/stmicro/stmmac to ethernet/synopsys
>>
>> I volunteer to do this task.
>>
>>>
>>>  These latest two have some relevant impacts.
>>>
>>>  This change should be propagated to all the platforms that are using:
>>>      CONFIG_SYNOPSYS_DWC_ETH_QOS and CONFIG_STMMAC_ETH
>>>  plus device-tree compatibility.
>>
>> I volunteer to do this task also.
>>
>>>
>>> - enhance the stmmac with new features and new glue (part of these
>>>  can be anticipated for sure).
>>
>> I have to implement 3 new features for now, but I will take some time for it, so
>> I would suggest to make the previous task and incrementally add features.
>>
>>>
>>> what do you think? does it make sense? If yes, we can also
>>> understand how/who starts.
>>>
>>> Regards,
>>> Peppe
>>
>> Thanks and regards.
>>
>> Joao
>>
>>>
>>>> Thanks.
>>>
>>
