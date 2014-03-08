From: Behan Webster <behanw@converseincode.com>
Subject: Re: [PATCH v2] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Sat, 08 Mar 2014 12:42:45 -0800
Message-ID: <531B80C5.7010408@converseincode.com>
References: <1394177091.4653.1.camel@jlt4.sipsolutions.net>	<1394241960-1764-1-git-send-email-behanw@converseincode.com> <CABikg9y_j-SDOsMj1C5uogP0HNj6bsB_ySVFtAh_oNgZ0swd=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dwmw2@infradead.org, pageexec@freemail.hu,
	=?UTF-8?B?SmFuLVNpbW9uIE3Dtmxs?= =?UTF-8?B?ZXI=?= <dl9pf@gmx.de>,
	=?UTF-8?B?Vmluw61jaXVzIFRpbnRp?= <viniciustinti@gmail.com>,
	Mark Charlebois <charlebm@gmail.com>
To: Sergei Antonov <saproj@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABikg9y_j-SDOsMj1C5uogP0HNj6bsB_ySVFtAh_oNgZ0swd=g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/08/14 12:29, Sergei Antonov wrote:
> On 8 March 2014 02:26,  <behanw@converseincode.com> wrote:
>> diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
>> index 7c7df47..3317578 100644
>> --- a/net/mac80211/aes_ccm.c
>> +++ b/net/mac80211/aes_ccm.c
>> @@ -23,12 +23,14 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
>>                                 u8 *data, size_t data_len, u8 *mic)
>>   {
>>          struct scatterlist assoc, pt, ct[2];
>> -       struct {
>> -               struct aead_request     req;
>> -               u8                      priv[crypto_aead_reqsize(tfm)];
>> -       } aead_req;
>>
>> -       memset(&aead_req, 0, sizeof(aead_req));
>> +       char aead_req_data[sizeof(struct aead_request) +
>> +                               crypto_aead_reqsize(tfm) +
>> +                               CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;
>> +
>> +       struct aead_request *aead_req = (void *) aead_req_data;
> Bad trick with regards to alignment.
> The alignment requirement for struct aead_request is stronger than
> what an array of chars may have.
Damn it. I should have seen that too. We had to do that in our related 
netfilter patch.

Good catch. Will fix.

Thanks,

Behan

-- 
Behan Webster
behanw@converseincode.com
