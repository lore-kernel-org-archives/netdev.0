From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3] net: bluetooth: hci_sock: Use 'const u32 *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Sat, 07 Feb 2015 11:52:54 -0800
Message-ID: <1423338774.2933.9.camel@perches.com>
References: <54D61229.9010904@sunrus.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Marcel Holtmann <marcel@holtmann.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chen Gang S <gang.chen@sunrus.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D61229.9010904@sunrus.com.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-02-07 at 21:24 +0800, Chen Gang S wrote:
> hci_test_bit() does not modify 2nd parameter, so it is better to let it
> be constant, or may cause build warning. The related warning (with
> allmodconfig under xtensa):
> 
>   net/bluetooth/hci_sock.c: In function 'hci_sock_sendmsg':
>   net/bluetooth/hci_sock.c:955:8: warning: passing argument 2 of 'hci_test_bit' discards 'const' qualifier from pointer target type [-Wdiscarded-array-qualifiers]
>           &hci_sec_filter.ocf_mask[ogf])) &&
>           ^
>   net/bluetooth/hci_sock.c:49:19: note: expected 'void *' but argument is of type 'const __u32 (*)[4] {aka const unsigned int (*)[4]}'
>    static inline int hci_test_bit(int nr, void *addr)
>                      ^
> 
> hci_test_bit() always treats 2nd parameter is u32, and all callers also
> know about it, so 2nd parameter of hci_test_bit() need use 'const u32 *'
> instead of 'void *'.
> 
> C language treats the array function parameter as a pointer, so the
> caller need not use '&' for the 2 demotion array, or it reports warning:
> 'const unsigned int (*)[4]' is different with 'const unsigned int *'.

I still think you are possibly papering over potential bugs
on big-endian 64 bit systems.

unsigned long vs u32.

How are the bits actually set?
