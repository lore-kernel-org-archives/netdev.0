From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v2] net: bluetooth: hci_sock: Use 'const void *' instead of 'void *' for 2nd parameter of hci_test_bit()
Date: Wed, 4 Feb 2015 13:09:47 -0800
Message-ID: <0AB99BEA-C379-439C-AD80-5F2122AE37E5@holtmann.org>
References: <54CFE8BE.5030700@sunrus.com.cn> <063D6719AE5E284EB5DD2968C1650D6D1CADA5E1@AcuExch.aculab.com> <54D27D68.7040501@cogentembedded.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	Chen Gang S <gang.chen-/B7AUNIrSHOPt1CcHtbs0g@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54D27D68.7040501-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

>>> -static inline int hci_test_bit(int nr, void *addr)
>>> +static inline int hci_test_bit(int nr, const void *addr)
>>>  {
>>>  	return *((__u32 *) addr + (nr >> 5)) & ((__u32) 1 << (nr & 31));
>>>  }
> 
>> Is there a 'standard' function lurking that will do the above.
>> On x86 the cpus 'bit test' instruction will handle bit numbers
>> greater than the word size - so it can be a single instruction.
> 
>   Of course, there's test_bit().

we did leave hci_test_bit in the code since there are some userspace facing API that we can not change. Remember that the origin of this code is from 2.4.6 kernel.

So we can only change this if you can ensure not to break the userspace API. So might want to write unit tests to ensure working HCI filter before even considering touching this.

Regards

Marcel
