From: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: check memory allocation failure
Date: Thu, 14 Sep 2017 14:47:17 +0000
Message-ID: <E0D909EE5BB15A4699798539EA149D7F077BED9A@ORSMSX103.amr.corp.intel.com>
References: <20170827063951.5975-1-christophe.jaillet@wanadoo.fr>
 <E0D909EE5BB15A4699798539EA149D7F0779685B@ORSMSX103.amr.corp.intel.com>
 <95a0bc80-8b41-d74f-8059-ae7181493120@wanadoo.fr>
 <309B89C4C689E141A5FF6A0C5FB2118B8C6A028B@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/13/17 7:24 PM, Brown, Aaron F wrote:
>> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
>> Of Christophe JAILLET
>> Sent: Monday, August 28, 2017 10:13 AM
>> To: Waskiewicz Jr, Peter <peter.waskiewicz.jr@intel.com>; Kirsher, Jeffrey T
>> <jeffrey.t.kirsher@intel.com>
>> Cc: netdev@vger.kernel.org; kernel-janitors@vger.kernel.org; intel-wired-
>> lan@lists.osuosl.org; linux-kernel@vger.kernel.org
>> Subject: Re: [Intel-wired-lan] [PATCH] igb: check memory allocation failure
>>
>> Le 28/08/2017 à 01:09, Waskiewicz Jr, Peter a écrit :
>>> On 8/27/17 2:42 AM, Christophe JAILLET wrote:
>>>> Check memory allocation failures and return -ENOMEM in such cases, as
>>>> already done for other memory allocations in this function.
>>>>
>>>> This avoids NULL pointers dereference.
>>>>
>>>> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
>>>> ---
>>>>     drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
>>>>     1 file changed, 2 insertions(+)
>>>>
> 
> This seems to be fine from a "it does not break in testing" perspective, so...
> 
> Tested-by: Aaron Brown <aaron.f.brown@intel.com
> 
>>> -PJ
>>>
>> Hi,
>>
>> in fact, there is no leak because the only caller of 'igb_sw_init()'
>> (i.e. 'igb_probe()'), already frees these resources in case of error,
>> see [1]
>>
>> These resources are also freed  in 'igb_remove()'.
>>
>> Best reagrds,
>> CJ
>>
>> [1]:
>> https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-
>> next.git/tree/drivers/net/ethernet/intel/igb/igb_main.c#n2775
> 
> But is PJ's comment saying that it is not really necessary?  If so I tend to lean towards the don't touch it if it's not broken perspective.

I guess I didn't respond after Christophe replied, sorry about that. 
The patch is good to me.  It's definitely catching an issue where we're 
not checking for a memory failure, then just follows the same 
de-allocation path on unwind.

If you want it:

Acked-by: PJ Waskiewicz <peter.waskiewicz.jr@intel.com>
