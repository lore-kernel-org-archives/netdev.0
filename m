From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: Re: [Regression][v3.10][v3.11] net: Kill link between CSUM and SG
 features.
Date: Wed, 17 Jul 2013 14:22:39 -0400
Message-ID: <51E6E0EF.1070309@canonical.com>
References: <51E58C45.1080708@canonical.com> <CALnjE+oCeo=T+F3BvTBtcV7oDMPLJAEz1p1sjRGxmE8Wq8gWAg@mail.gmail.com> <51E5A4CA.20902@canonical.com> <CALnjE+rhvmYPEXv=1F1HEe3VsgCNN1SKg5UwTuFatQUm9e9S2w@mail.gmail.com> <51E6B8B0.2080103@canonical.com> <9d96a2fb07b9474b927f6f4538a0845e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ben.howard@canonical.com" <ben.howard@canonical.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
	"alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:54960 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756689Ab3GQSW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 14:22:58 -0400
In-Reply-To: <9d96a2fb07b9474b927f6f4538a0845e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2013 01:45 PM, Haiyang Zhang wrote:
>
>> -----Original Message-----
>> From: Joseph Salisbury [mailto:joseph.salisbury@canonical.com]
>> Sent: Wednesday, July 17, 2013 8:31 AM
>> To: Pravin Shelar
>> Cc: davem@davemloft.net; ben.howard@canonical.com;
>> edumazet@google.com; xiyou.wangcong@gmail.com;
>> alexander.h.duyck@intel.com; jiri@resnulli.us; netdev@vger.kernel.org;
>> LKML; KY Srinivasan; Haiyang Zhang
>> Subject: Re: [Regression][v3.10][v3.11] net: Kill link between CSUM and SG
>> features.
>>
>> On 07/16/2013 04:50 PM, Pravin Shelar wrote:
>>> On Tue, Jul 16, 2013 at 12:53 PM, Joseph Salisbury
>>> <joseph.salisbury@canonical.com> wrote:
>>>> On 07/16/2013 02:29 PM, Pravin Shelar wrote:
>>>>> On Tue, Jul 16, 2013 at 11:09 AM, Joseph Salisbury
>>>>> <joseph.salisbury@canonical.com> wrote:
>>>>>> Hi Pravin,
>>>>>>
>>>>>> A bug was opened against the Ubuntu kernel[0].  After a kernel
>>>>>> bisect, it was found that reverting the following commit resolved this
>> bug:
>>>>>> commit ec5f061564238892005257c83565a0b58ec79295
>>>>>> Author: Pravin B Shelar <pshelar@nicira.com>
>>>>>> Date:   Thu Mar 7 09:28:01 2013 +0000
>>>>>>
>>>>>>     net: Kill link between CSUM and SG features.
>>>>>>
>>>>>>
>>>>>> The regression was introduced as of v3.10-rc1.
>>>>>>
>>>>>> I see that you are the author of this patch, so I wanted to run
>>>>>> this by you.  I was thinking of requesting a revert for v3.11, but
>>>>>> I wanted to get your feedback first.
>>>>>>
>>>>>>
>>>>> This issue was reported before and turning off sg solves problem for
>>>>> HyperV driver. Drivers (intel and bnx2x) that I tested works fine
>>>>> with this patch. Have you seen the issue on any other NIC?
>>>> Thanks for the feedback.  We have only seen it on Intel hardware.
>>>> Can you send a pointer to the patch? If so, we can provide some
>>>> additional testing.  Do you plan on submitting the patch for inclusion in
>> 3.11?
>>>>
>>> What I mean is I do not see any problem with the patch that you have
>>> pointed out on ixgbe and bnx2x platforms. HyperV problem went away
>>> with disabling sg by ethtool utility.
>> Yes, we also see that the problem goes away when disabling sg with ethtool.
>> There was a significant improvement in throughput with sg enabled, so it's
>> unfortunate it must be disabled.
>>
>>> Can you also give me more information about regression you are seeing
>>> like driver name, features of the NIC set and features of device
>>> without this patch. Does any other NIC than HyperV having this issue?
>> Some details info about the HyperV guest can be seen here:
>> http://paste.ubuntu.com/5884549/
>>
>> In that output, you will see that scatter-gather is off, which was done
>> manually.
>>
>> Only a HyperV NIC is having this issue.
> I have submitted a patch which has been accepted, and queued for -stable branch
> as well: http://patchwork.ozlabs.org/patch/259596/
> It removes the NETIF_F_SG flag from the hv_netvsc driver, which doesn't currently
> support SG mode.
>
> Thanks,
> - Haiyang
>
That's great.  Thanks, Haiyang!
