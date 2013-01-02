From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] ath9k_htc: Fix skb leaks
Date: Tue, 01 Jan 2013 22:57:07 -0600
Message-ID: <50E3BE23.3010102@lwfinger.net>
References: <1357098567-8558-1-git-send-email-Larry.Finger@lwfinger.net> <20707.47067.474241.813195@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	ath9k-devel@lists.ath9k.org, linux-kernel@vger.kernel.org
To: Sujith Manoharan <sujith@msujith.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20707.47067.474241.813195@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/01/2013 10:30 PM, Sujith Manoharan wrote:
> Larry Finger wrote:
>> diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
>> index 4a9570d..a304748 100644
>> --- a/drivers/net/wireless/ath/ath9k/htc_hst.c
>> +++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
>> @@ -278,10 +278,12 @@ int htc_connect_service(struct htc_target *target,
>>   	if (!time_left) {
>>   		dev_err(target->dev, "Service connection timeout for: %d\n",
>>   			service_connreq->service_id);
>> -		return -ETIMEDOUT;
>> +		ret = -ETIMEDOUT;
>> +		goto err;
>>   	}
>>
>>   	*conn_rsp_epid = target->conn_rsp_epid;
>> +	kfree_skb(skb);
>>   	return 0;
>>   err:
>>   	kfree_skb(skb);
> ath9k_htc_txcompletion_cb()
> The allocated skb should be freed in the TX completion hander,
> ath9k_htc_txcompletion_cb() - doing it in htc_connect_service() is wrong, I think.

My only counter argument is that none of the other paths that get to 
ath9k_htc_txcompletion_cb() leak the skb. It only happens for the path that goes 
through htc_connect_service().

Larry
