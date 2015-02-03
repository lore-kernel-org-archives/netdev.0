From: Chen Gang S <gang.chen-/B7AUNIrSHOPt1CcHtbs0g@public.gmane.org>
Subject: Re: [PATCH v2] net: bluetooth: hci_sock: Use 'const void *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Tue, 03 Feb 2015 10:32:11 +0800
Message-ID: <54D0332B.6050701@sunrus.com.cn>
References: <54CFE8BE.5030700@sunrus.com.cn> <1422912017.30476.28.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422912017.30476.28.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/3/15 05:20, Joe Perches wrote:
> On Tue, 2015-02-03 at 05:14 +0800, Chen Gang S wrote:
>> hci_test_bit() does not modify 2nd parameter, so it is better to let it
>> be constant, or may cause build warning. The related warning (with
>> allmodconfig under xtensa):
> []
>> diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
> []
>> @@ -46,7 +46,7 @@ struct hci_pinfo {
>>  	unsigned short    channel;
>>  };
>>  
>> -static inline int hci_test_bit(int nr, void *addr)
>> +static inline int hci_test_bit(int nr, const void *addr)
>>  {
>>  	return *((__u32 *) addr + (nr >> 5)) & ((__u32) 1 << (nr & 31));
>>  }
> 
> It's probably better to use const __u32 * here too, but the
> real thing I wonder is whether or not there's an issue with
> one of the 2 uses of this function.
> 
> One of them passes a unsigned long *, the other a u32 *.
> 
> $ git grep -w hci_test_bit
> net/bluetooth/hci_sock.c:static inline int hci_test_bit(int nr, void *addr)
> net/bluetooth/hci_sock.c:       if (!hci_test_bit(flt_event, &flt->event_mask))
> net/bluetooth/hci_sock.c:                    !hci_test_bit(ocf & HCI_FLT_OCF_BITS,
> net/bluetooth/hci_sock.c-                                  &hci_sec_filter.ocf_mask[ogf])) &&
> 
> hci_sec_filter.ocf_mask is __u32
> but flt->event_mask is unsigned long.
> 
> Any possible issue here on 64-bit systems?
> 

For me, it can not cause issue on 64-bit systems. hci_test_bit() treats
'addr' as "__u32 *", and has to use the pointer to do something.


Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
