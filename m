From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v3] net: bluetooth: hci_sock: Use 'const u32 *' instead of 'void *' for 2nd parameter of hci_test_bit()
Date: Sun, 8 Feb 2015 12:17:14 -0800
Message-ID: <BD721CC9-DD4D-480D-98E6-89CA868BA285@holtmann.org>
References: <54D61229.9010904@sunrus.com.cn> <1423338774.2933.9.camel@perches.com> <54D6A729.1070905@sunrus.com.cn> <54D75698.7010808@sunrus.com.cn>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Joe Perches <joe@perches.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chen Gang S <gang.chen@sunrus.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D75698.7010808@sunrus.com.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chen,

>>>> hci_test_bit() does not modify 2nd parameter, so it is better to let it
>>>> be constant, or may cause build warning. The related warning (with
>>>> allmodconfig under xtensa):
>>>> 
>>>>  net/bluetooth/hci_sock.c: In function 'hci_sock_sendmsg':
>>>>  net/bluetooth/hci_sock.c:955:8: warning: passing argument 2 of 'hci_test_bit' discards 'const' qualifier from pointer target type [-Wdiscarded-array-qualifiers]
>>>>          &hci_sec_filter.ocf_mask[ogf])) &&
>>>>          ^
>>>>  net/bluetooth/hci_sock.c:49:19: note: expected 'void *' but argument is of type 'const __u32 (*)[4] {aka const unsigned int (*)[4]}'
>>>>   static inline int hci_test_bit(int nr, void *addr)
>>>>                     ^
>>>> 
>>>> hci_test_bit() always treats 2nd parameter is u32, and all callers also
>>>> know about it, so 2nd parameter of hci_test_bit() need use 'const u32 *'
>>>> instead of 'void *'.
>>>> 
>>>> C language treats the array function parameter as a pointer, so the
>>>> caller need not use '&' for the 2 demotion array, or it reports warning:
>>>> 'const unsigned int (*)[4]' is different with 'const unsigned int *'.
>>> 
>>> I still think you are possibly papering over potential bugs
>>> on big-endian 64 bit systems.
>>> 
>>> unsigned long vs u32.
>>> 
>>> How are the bits actually set?
>>> 
>> 
>>> From current usage of event_mask, "(u32 *) f->event_mask" is only for
>> event_mask data storage, not for calculation (always as "u32 *" for
>> calculation).
>> 
>>  [root@localhost linux-next]# grep -rn "\<event_mask\>" include/net/bluetooth net/bluetooth
>>  include/net/bluetooth/hci_sock.h:51:	unsigned long event_mask[2];
> 
> e.g. use "unsigned char event_mask[2 * sizeof(unsigned long)]" instead
> of "unsigned long event_mask[2]".
> 
> There is still no any issue within "hci_sock.c" (although I am not sure
> whether this modification may cause issues in another modules outside
> kernel).

what about writing a test case for userspace that ensures that things are working correctly. As I said before, we left it this way since it is part of the API.

Regards

Marcel
