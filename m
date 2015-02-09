From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v3] net: bluetooth: hci_sock: Use 'const u32 *' instead of 'void *' for 2nd parameter of hci_test_bit()
Date: Mon, 9 Feb 2015 08:51:20 -0800
Message-ID: <DECB4016-B7D2-4C0B-A055-ED3282F727EE@holtmann.org>
References: <54D61229.9010904@sunrus.com.cn> <1423338774.2933.9.camel@perches.com> <54D6A729.1070905@sunrus.com.cn> <54D75698.7010808@sunrus.com.cn> <BD721CC9-DD4D-480D-98E6-89CA868BA285@holtmann.org> <54D82D7D.3000308@sunrus.com.cn> <063D6719AE5E284EB5DD2968C1650D6D1CAE0823@AcuExch.aculab.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Chen Gang S <gang.chen@sunrus.com.cn>,
	Joe Perches <joe@perches.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE0823@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

>> So at present, in kernel part, we can only say the original authors
>> intended to do like this. And only within kernel part, it can not cause
>> issue. I guess, original authors originally knew what we talk about.
> 
> I've just searched for hci_u*filter it is all horrid.
> Look at the code for get/set_sockopt of HCI_FILTER.
> Someone seems to have done a complete 'bodge job' of fixing the user interface
> for apps (32bit and 64bit) on 64bit kernels.

we are actually fully aware of that. Just keep in mind that this code is from 2.4.6 kernel and with that most likely 14 years old by now. Unfortunately it ended up as userspace API.

>> This patch is for fixing building warnings without any negative effect.
>> And most of us are not the suitable members to continue analyzing. So
>> at present, for me, we can accept this patch.
> 
> And, not uncommonly, it has shown up a 'bag of worms'.
> 
> If you change 'hci_filter' to contain u32[2] then you can drop
> all of the casts and the temporary structures in the sockopt code.
> Just be aware of the tail-padding.

I am happy to accept patches for this, but we might want to get some unit tests into BlueZ userspace code first to make sure that nothing breaks.

Regards

Marcel
