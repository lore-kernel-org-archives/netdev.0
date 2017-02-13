From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 6/7] staging: r8712u: Fix Sparse warnings in
 rtl871x_ioctl_linux.c
Date: Mon, 13 Feb 2017 09:54:00 -0600
Message-ID: <eb9e61a8-dee1-ec86-d477-5df7955209e8@lwfinger.net>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
 <20170211033030.28827-7-Larry.Finger@lwfinger.net>
 <063D6719AE5E284EB5DD2968C1650D6DB0284E26@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0284E26@AcuExch.aculab.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 02/13/2017 05:27 AM, David Laight wrote:
> From: Larry Finger
>> Sent: 11 February 2017 03:30
>> Sparse reports the following:
>>   CHECK   drivers/staging/rtl8712/rtl871x_ioctl_linux.c
>> drivers/staging/rtl8712/rtl871x_ioctl_linux.c:1422:46: warning: restricted __le16 degrades to integer
>> drivers/staging/rtl8712/rtl871x_ioctl_linux.c:1424:46: warning: restricted __le16 degrades to integer
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>  drivers/staging/rtl8712/rtl871x_ioctl_linux.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
>> b/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
>> index 0dc18d6..f4167f1 100644
>> --- a/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
>> +++ b/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
>> @@ -1419,9 +1419,9 @@ static int r8711_wx_get_rate(struct net_device *dev,
>>  			ht_cap = true;
>>  			pht_capie = (struct ieee80211_ht_cap *)(p + 2);
>>  			memcpy(&mcs_rate, pht_capie->supp_mcs_set, 2);
>> -			bw_40MHz = (pht_capie->cap_info &
>> +			bw_40MHz = (le16_to_cpu(pht_capie->cap_info) &
>>  				    IEEE80211_HT_CAP_SUP_WIDTH) ? 1 : 0;
>> -			short_GI = (pht_capie->cap_info &
>> +			short_GI = (le16_to_cpu(pht_capie->cap_info) &
>>  				    (IEEE80211_HT_CAP_SGI_20 |
>>  				    IEEE80211_HT_CAP_SGI_40)) ? 1 : 0;
>
> You've added a byteswap on le systems - so the title is wrong.
> You need to sort out whether the byteswap is needed or not.
>
> Also it is best to byteswap the constant.

Yes, I could byteswap the constant rather than the variable, but I prefer to 
have both be in cpu order. That way there will be no confusion when that 
quantity is used later. In this case, both results are boolean and it would not 
make a difference.

I do not understand the comment about the title being wrong. All multi-byte 
quantities in struct ieee80211_ht_cap are little endian. For the code to work on 
BE hardware, a byteswap is necessary. On LE hardware, le16_to_cpu() is defined 
as ((__force __u16)(__le16)(x)), which does not result in a byteswap.

Larry
