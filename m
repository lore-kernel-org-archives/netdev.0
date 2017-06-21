From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH][net-next] qtnfmac: fix uninitialized return code in ret
Date: Wed, 21 Jun 2017 14:55:44 +0100
Message-ID: <36a321a5-5134-9284-ca3d-663723880156@canonical.com>
References: <20170621132530.11937-1-colin.king@canonical.com>
 <20170621135402.e4iwovvmdumarzqj@bars>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Igor Mitsyanko <imitsyanko@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        Bindu Therthala <btherthala@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        Sergei Maksimenko <smaksimenko@quantenna.com>,
        Johannes Berg <johannes.berg@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45774 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdFUNzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 09:55:48 -0400
In-Reply-To: <20170621135402.e4iwovvmdumarzqj@bars>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/06/17 14:54, Sergey Matyukevich wrote:
>> The return value ret is unitialized and garbage is being returned
>> for the three different error conditions when setting up the PCIe
>> BARs. Fix this by initializing ret to  -ENOMEM to indicate that
>> the BARs failed to be setup correctly.
>>
>> Detected by CoverityScan, CID#1437563 ("Unitialized scalar variable")
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> ---
>>  drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c b/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
>> index f93b27f3a236..7fc4f0d6a9ad 100644
>> --- a/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
>> +++ b/drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c
>> @@ -247,7 +247,7 @@ static void qtnf_pcie_free_shm_ipc(struct qtnf_pcie_bus_priv *priv)
>>
>>  static int qtnf_pcie_init_memory(struct qtnf_pcie_bus_priv *priv)
>>  {
>> -       int ret;
>> +       int ret = -ENOMEM;
>>
>>         priv->sysctl_bar = qtnf_map_bar(priv, QTN_SYSCTL_BAR);
>>         if (IS_ERR_OR_NULL(priv->sysctl_bar)) {
>> --
> 
> Thanks !
> 
> Reviewed-by: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>
> 
> By the way, could you please use the recepient list suggested by
> get_maintainer.pl script from the kernel scripts directory.

Yep, I did.

> 
> Regards,
> Sergey
> 
