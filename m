From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] net: bluetooth: hci_sock: Use 'const void *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Thu, 5 Feb 2015 10:14:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CADC42B@AcuExch.aculab.com>
References: <54CFE8BE.5030700@sunrus.com.cn>
 <063D6719AE5E284EB5DD2968C1650D6D1CADA5E1@AcuExch.aculab.com>
 <54D27D68.7040501@cogentembedded.com>
 <0AB99BEA-C379-439C-AD80-5F2122AE37E5@holtmann.org>
 <54D29379.8050104@sunrus.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Chen Gang S' <gang.chen@sunrus.com.cn>,
	Marcel Holtmann <marcel@holtmann.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D29379.8050104@sunrus.com.cn>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chen Gang S [mailto:gang.chen@sunrus.com.cn]
> On 2/5/15 05:09, Marcel Holtmann wrote:
> > Hi Sergei,
> >
> >>>> -static inline int hci_test_bit(int nr, void *addr)
> >>>> +static inline int hci_test_bit(int nr, const void *addr)
> >>>>  {
> >>>>  	return *((__u32 *) addr + (nr >> 5)) & ((__u32) 1 << (nr & 31));
> >>>>  }
> >>
> >>> Is there a 'standard' function lurking that will do the above.
> >>> On x86 the cpus 'bit test' instruction will handle bit numbers
> >>> greater than the word size - so it can be a single instruction.
> >>
> >>   Of course, there's test_bit().
> >
> > we did leave hci_test_bit in the code since there are some userspace facing
> > API that we can not change. Remember that the origin of this code is
> > from 2.4.6 kernel.
> >
> > So we can only change this if you can ensure not to break the userspace API.
> > So might want to write unit tests to ensure working HCI filter before even
> > considering touching this.
> >
> 
> For me, we have to remain hci_test_bit(), it is for "__u32 *" (which we
> can not change). The common test_bit() is for "unsigned long *", in this
> case, I guess it may cause issue under 64-bit environments.

Except that half the time you are passing a 'long *' and you haven't
explained why this isn't broken on 64bit architectures.

Note that on LE systems the size of the accesses used to access a dense
bit array don't matter. This is not true of BE systems.

	David
