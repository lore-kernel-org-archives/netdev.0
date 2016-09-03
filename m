From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] ath10k: fix memory leak on caldata on error exit path
Date: Sat, 3 Sep 2016 17:33:40 +0100
Message-ID: <4e586d21-51cf-768c-4aee-9b0a147f1183@canonical.com>
References: <1471268785-11576-1-git-send-email-colin.king@canonical.com>
 <87r392z4ox.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r392z4ox.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/09/16 16:45, Valo, Kalle wrote:
> Colin King <colin.king@canonical.com> writes:
> 
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> caldata is not being free'd on the error exit path, causing
>> a memory leak. kfree it to fix the leak.
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> ---
>>  drivers/net/wireless/ath/ath10k/pci.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
>> index 9a22c47..886337c 100644
>> --- a/drivers/net/wireless/ath/ath10k/pci.c
>> +++ b/drivers/net/wireless/ath/ath10k/pci.c
>> @@ -2725,6 +2725,7 @@ static int ath10k_pci_hif_fetch_cal_eeprom(struct ath10k *ar, void **data,
>>  	return 0;
>>  
>>  err_free:
>> +	kfree(caldata);
>>  	kfree(data);
>>  
>>  	return -EINVAL;
> 
> I don't think we should free data at all:
> 
> static int ath10k_download_cal_eeprom(struct ath10k *ar)
> {
> 	size_t data_len;
> 	void *data = NULL;
> 	int ret;
> 
> 	ret = ath10k_hif_fetch_cal_eeprom(ar, &data, &data_len);
> 
> Instead we should free only caldata, right?
> 
Yep, good catch, I'll send V2 later.

Colin
