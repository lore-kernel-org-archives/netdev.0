From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3] net: bluetooth: hci_sock: Use 'const u32 *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Mon, 9 Feb 2015 16:57:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE0B02@AcuExch.aculab.com>
References: <54D61229.9010904@sunrus.com.cn>
 <1423338774.2933.9.camel@perches.com> <54D6A729.1070905@sunrus.com.cn>
 <54D75698.7010808@sunrus.com.cn>
 <BD721CC9-DD4D-480D-98E6-89CA868BA285@holtmann.org>
 <54D82D7D.3000308@sunrus.com.cn>
 <063D6719AE5E284EB5DD2968C1650D6D1CAE0823@AcuExch.aculab.com>
 <DECB4016-B7D2-4C0B-A055-ED3282F727EE@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
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
To: 'Marcel Holtmann' <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DECB4016-B7D2-4C0B-A055-ED3282F727EE@holtmann.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann
> Hi David,
> 
> >> So at present, in kernel part, we can only say the original authors
> >> intended to do like this. And only within kernel part, it can not cause
> >> issue. I guess, original authors originally knew what we talk about.
> >
> > I've just searched for hci_u*filter it is all horrid.
> > Look at the code for get/set_sockopt of HCI_FILTER.
> > Someone seems to have done a complete 'bodge job' of fixing the user interface
> > for apps (32bit and 64bit) on 64bit kernels.
> 
> we are actually fully aware of that. Just keep in mind that this code is from 2.4.6 kernel and with
> that most likely 14 years old by now. Unfortunately it ended up as userspace API.

AFAICT the userspace API is always __u32[2] the long[2] is never exposed
to userspace (certainly not through the socket option code).

Quite why all the casts were added - instead of changing the type
is probably hidden in the annals of the source repo.
Some serious archaeology might be in order.

	David
