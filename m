From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next] be2net: don't report EVB for older chipsets when
 SR-IOV is disabled
Date: Thu, 11 Feb 2016 12:38:15 +0100
Message-ID: <56BC72A7.3040100@redhat.com>
References: <1455106400-16330-1-git-send-email-ivecera@redhat.com>
 <CAKvpyk1u=59YZLoX9kTpTFm0=bXdyE-LaZpCobZwmWo+wa5RTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ajit Khaparde <ajit.khaparde@broadcom.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>
To: Sathya Perla <sathya.perla@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbcBKLiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 06:38:21 -0500
In-Reply-To: <CAKvpyk1u=59YZLoX9kTpTFm0=bXdyE-LaZpCobZwmWo+wa5RTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.2.2016 10:56, Sathya Perla wrote:
> On Wed, Feb 10, 2016 at 1:13 PM, Ivan Vecera <ivecera@redhat.com> wrote:
>>
>> The EVB (virtual bridge) functionality should be disabled on older BE3
>> and Lancer chips if SR-IOV is disabled in the NIC's BIOS. This setting
>> is identified by the zero value of total VFs reported by the card.
>> The GET_HSW_CONFIG command cannot be used as it is not supported > by these older chipset's FW.
>>
> ..
>> ---
>>   drivers/net/ethernet/emulex/benet/be_main.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
>> index 9c1fc9d..886fe95 100644
>> --- a/drivers/net/ethernet/emulex/benet/be_main.c
>> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
>> @@ -4588,6 +4588,8 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>>
>>          /* BE and Lancer chips support VEB mode only */
>>          if (BEx_chip(adapter) || lancer_chip(adapter)) {
>> +               if (!pci_sriov_get_totalvfs(adapter->pdev))
>> +                       return 0;
>
> Ivan, could you add a one line comment above this check that says "On
> BE3/Lancer the VEB is disabled in non-SRIOV profiles". This is to
> differentiate this behavior from Skyhawk, where the VEB may be enabled
> even in non-SRIOV profiles, like nPAR...
>
> thanks,
> -Sathya
>
Sure Sathya, will send v2.

Ivan
