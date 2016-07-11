From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless
 ucode is loaded
Date: Mon, 11 Jul 2016 13:00:51 -0400
Message-ID: <5783D0C3.20804@redhat.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com> <1468253261.25088.126.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linuxwifi <linuxwifi@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: "Coelho, Luciano" <luciano.coelho@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468253261.25088.126.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/11/2016 12:07 PM, Coelho, Luciano wrote:
> On Mon, 2016-07-11 at 11:18 -0400, Prarit Bhargava wrote:
>> Didn't get any feedback or review comments on this patch.  Resending
>> ...
>>
>> P.
> 
> Sorry, this got flooded down my inbox.

NP, Luciano -- My worry was that it hadn't been seen or didn't make it out to
the list.

I'm being a bit impatient too ;)

P.

> 
> 
>> ---8<---
>>
>> The iwlwifi driver implements a thermal zone and hwmon device, but
>> returns -EIO on temperature reads if the firmware isn't loaded.  This
>> results in the error
>>
>> iwlwifi-virtual-0
>> Adapter: Virtual device
>> ERROR: Can't get value of subfeature temp1_input: I/O error
>> temp1:            N/A
>>
>> being output when using sensors from the lm-sensors package.  Since
>> the temperature cannot be read unless the ucode is loaded there is no
>> reason to add the interface only to have it return an error 100% of
>> the time.
>>
>> This patch moves the firmware check to
>> iwl_mvm_thermal_zone_register() and
>> stops the thermal zone from being created if the ucode hasn't been
>> loaded.
>>
>> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
>> Cc: Johannes Berg <johannes.berg@intel.com>
>> Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
>> Cc: Luca Coelho <luciano.coelho@intel.com>
>> Cc: Intel Linux Wireless <linuxwifi@intel.com>
>> Cc: Kalle Valo <kvalo@codeaurora.org>
>> Cc: Chaya Rachel Ivgi <chaya.rachel.ivgi@intel.com>
>> Cc: Sara Sharon <sara.sharon@intel.com>
>> Cc: linux-wireless@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> ---
> 
> I have now sent it for review on our internal tree.
> 
> --
> Luca.
> 
