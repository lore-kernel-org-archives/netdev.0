From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH] Documentation: document the gianfar tx vlan offload issue
Date: Fri, 4 Apr 2014 10:10:59 +0300
Message-ID: <533E5B03.2050801@freescale.com>
References: <1396580685-17156-1-git-send-email-roy.qing.li@gmail.com> <533E5A19.6060701@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <Yanjun.Zhu@windriver.com>
To: <roy.qing.li@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:1652
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752217AbaDDHLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 03:11:08 -0400
In-Reply-To: <533E5A19.6060701@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/2014 10:07 AM, Claudiu Manoil wrote:
> On 4/4/2014 6:04 AM, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> The commit b852b72087[gianfar: fix bug caused by 87c288c6e9] and
>> e2c53be223
>> [gianfar: fix default tx vlan offload feature flag] disabled tx vlan
>> offload
>> from dev->feature, since enabling vlan tag insertion leads to unusable
>> connections on some configurations.
>>
>> But this feature is in dev->hw_feature still, and a user can enable it by
>> "ethtool", so document the tx vlan offload issue.
>>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
>> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
>> ---
>>   Documentation/networking/gianfar.txt |   12 ++++++++++++
>>   1 file changed, 12 insertions(+)
>>
>> diff --git a/Documentation/networking/gianfar.txt
>> b/Documentation/networking/gianfar.txt
>> index ad474ea..2d3dbe6 100644
>> --- a/Documentation/networking/gianfar.txt
>> +++ b/Documentation/networking/gianfar.txt
>> @@ -51,6 +51,18 @@ configuring VLANs.  The gianfar driver supports
>> hardware insertion and
>>   extraction of VLAN headers, but not filtering.  Filtering will be
>>   done by the kernel.
>> +But if tx vlan tag hardware insertion is enabled, and a vlan-device is
>> +created, the physical device which vlan device is on will be unable to
>> +work, like:
>> +
>> +    $ethtool -K eth0 tx-vlan-stag-hw-insert on
>> +    $ifconfig eth0 192.168.1.13/24 up
>> +
>> +    $vconfig add eth0 4091
>> +    $ifconfig eth0.4091 10.1.1.13/24 up
>> +eth0.4091 can work, but eth0 can not work, since eth0 sends the insane
>> +packets out.
>> +
> I don't really like this, this is hardly a technical explanation.
> ("insane packets"?)
> Please have a look at the HW reference manual.  There you have the
> description
> of the VLAN extraction feature (see VLEX).
>
And VLAN insertion (VLINS) as well, for that matter.
