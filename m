From: Chen Gang S <gang.chen@sunrus.com.cn>
Subject: Re: [PATCH v2] net: bluetooth: hci_sock: Use 'const void *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Tue, 03 Feb 2015 10:59:34 +0800
Message-ID: <54D03996.1070503@sunrus.com.cn>
References: <54CFE8BE.5030700@sunrus.com.cn> <1422912017.30476.28.camel@perches.com> <54D0332B.6050701@sunrus.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D0332B.6050701@sunrus.com.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2/3/15 10:32, Chen Gang S wrote:
> On 2/3/15 05:20, Joe Perches wrote:
>> On Tue, 2015-02-03 at 05:14 +0800, Chen Gang S wrote:
>>> hci_test_bit() does not modify 2nd parameter, so it is better to let it
>>> be constant, or may cause build warning. The related warning (with
>>> allmodconfig under xtensa):
>> []
>>> diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
>> []
>>> @@ -46,7 +46,7 @@ struct hci_pinfo {
>>>  	unsigned short    channel;
>>>  };
>>>  
>>> -static inline int hci_test_bit(int nr, void *addr)
>>> +static inline int hci_test_bit(int nr, const void *addr)
>>>  {
>>>  	return *((__u32 *) addr + (nr >> 5)) & ((__u32) 1 << (nr & 31));
>>>  }
>>
>> It's probably better to use const __u32 * here too, but the
>> real thing I wonder is whether or not there's an issue with
>> one of the 2 uses of this function.
>>
>> One of them passes a unsigned long *, the other a u32 *.
>>
>> $ git grep -w hci_test_bit
>> net/bluetooth/hci_sock.c:static inline int hci_test_bit(int nr, void *addr)
>> net/bluetooth/hci_sock.c:       if (!hci_test_bit(flt_event, &flt->event_mask))
>> net/bluetooth/hci_sock.c:                    !hci_test_bit(ocf & HCI_FLT_OCF_BITS,
>> net/bluetooth/hci_sock.c-                                  &hci_sec_filter.ocf_mask[ogf])) &&
>>
>> hci_sec_filter.ocf_mask is __u32
>> but flt->event_mask is unsigned long.
>>
>> Any possible issue here on 64-bit systems?
>>
> 
> For me, it can not cause issue on 64-bit systems. hci_test_bit() treats
> 'addr' as "__u32 *", and has to use the pointer to do something.
> 

'event_mask' is intended to type cast to "__u32 *" within 'hci_sock.c'.
So for me, "const __u32 *" is better than "const void *" for 2nd
parameter of hci_test_bit().

If what I said above is correct, and also if necessary, I shall patch v3
for it.


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
