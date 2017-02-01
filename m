From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] be2net: fix initial MAC setting
Date: Wed, 01 Feb 2017 11:12:19 -0500 (EST)
Message-ID: <20170201.111219.1380185836663861761.davem@davemloft.net>
References: <20170131190131.3347-1-cera@cera.cz>
        <CAHHeUGU_7XUmBpEhzOBEsGqaoMFy=ddwu8xSuDFenCXfoVapVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cera@cera.cz, netdev@vger.kernel.org, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, somnath.kotur@broadcom.com
To: sriharsha.basavapatna@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdBAQMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 11:12:30 -0500
In-Reply-To: <CAHHeUGU_7XUmBpEhzOBEsGqaoMFy=ddwu8xSuDFenCXfoVapVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Date: Wed, 1 Feb 2017 11:21:29 +0530

> On Wed, Feb 1, 2017 at 12:31 AM, Ivan Vecera <cera@cera.cz> wrote:
>> Recent commit 34393529163a ("be2net: fix MAC addr setting on privileged
>> BE3 VFs") allows privileged BE3 VFs to set its MAC address during
>> initialization. Although the initial MAC for such VFs is already
>> programmed by parent PF the subsequent setting performed by VF is OK,
>> but in certain cases (after fresh boot) this command in VF can fail.
>>
>> The MAC should be initialized only when:
>> 1) no MAC is programmed (always except BE3 VFs during first init)
>> 2) programmed MAC is different from requested (e.g. MAC is set when
>>    interface is down). In this case the initial MAC programmed by PF
>>    needs to be deleted.
>>
>> The adapter->dev_mac contains MAC address currently programmed in HW so
>> it should be zeroed when the MAC is deleted from HW and should not be
>> filled when MAC is set when interface is down in be_mac_addr_set() as
>> no programming is performed in this case.
>>
>> Example of failure without the fix (immediately after fresh boot):
>>
>> # ip link set eth0 up  <- eth0 is BE3 PF
>> be2net 0000:01:00.0 eth0: Link is Up
>>
>> # echo 1 > /sys/class/net/eth0/device/sriov_numvfs  <- Create 1 VF
>> ...
>> be2net 0000:01:04.0: Emulex OneConnect(be3): VF  port 0
>>
>> # ip link set eth8 up  <- eth8 is created privileged VF
>> be2net 0000:01:04.0: opcode 59-1 failed:status 1-76
>> RTNETLINK answers: Input/output error
>>
>> # echo 0 > /sys/class/net/eth0/device/sriov_numvfs  <- Delete VF
>> iommu: Removing device 0000:01:04.0 from group 33
>> ...
>>
>> # echo 1 > /sys/class/net/eth0/device/sriov_numvfs  <- Create it again
>> iommu: Removing device 0000:01:04.0 from group 33
>> ...
>>
>> # ip link set eth8 up
>> be2net 0000:01:04.0 eth8: Link is Up
>>
>> Initialization is now OK.
>>
>> v2 - Corrected the comment and condition check suggested by Suresh & Harsha
>>
>> Fixes: 34393529163a ("be2net: fix MAC addr setting on privileged BE3 VFs")
>> Cc: Sathya Perla <sathya.perla@broadcom.com>
>> Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
>> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
>> Cc: Somnath Kotur <somnath.kotur@broadcom.com>
>> Signed-off-by: Ivan Vecera <cera@cera.cz>
 ...
> Acked-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>

Applied, thanks everyone.
