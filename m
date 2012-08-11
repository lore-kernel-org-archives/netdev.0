From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
Date: Sat, 11 Aug 2012 15:15:24 +0400
Message-ID: <50263ECC.4060501@parallels.com>
References: <20120810125701.7115.71612.stgit@localhost.localdomain> <50254FA6.3060806@zytor.com> <20120810192628.79a34d28@pyramind.ukuu.org.uk> <20120810191149.GA17985@fieldses.org> <20120810202818.06236f46@pyramind.ukuu.org.uk> <50259494.8060304@zytor.com> <5025FA5A.4090403@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>,
	"devel@openvz.org" <devel@openvz.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5025FA5A.4090403@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

11.08.2012 10:23, Pavel Emelyanov =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 08/11/2012 03:09 AM, H. Peter Anvin wrote:
>> On 08/10/2012 12:28 PM, Alan Cox wrote:
>>> Explicitly for Linux yes - this is not generally true of the AF_UNI=
X
>>> socket domain and even the permissions aspect isn't guaranteed to b=
e
>>> supported on some BSD environments !
>> Yes, but let's worry about what the Linux behavior should be.
>>
>>> The name is however just a proxy for the socket itself. You don't e=
ven
>>> get a device node in the usual sense or the same inode in the file =
system
>>> space.
>>
>> No, but it is looked up the same way any other inode is (the differe=
nce
>> between FIFOs and sockets is that sockets have separate connections,
>> which is also why open() on sockets would be nice.)
>>
>> However, there is a fundamental difference between AF_UNIX sockets a=
nd
>> open(), and that is how the pathname is delivered.  It thus would ma=
ke
>> more sense to provide the openat()-like information in struct
>> sockaddr_un, but that may be very hard to do in a sensible way.  In =
that
>> sense it perhaps would be cleaner to be able to do an open[at]() on =
the
>> socket node with O_PATH (perhaps there should be an O_SOCKET option,
>> even?) and pass the resulting file descriptor to bind() or connect()=
=2E
> I vote for this (openat + O_WHATEVER on a unix socket) as well. It wi=
ll
> help us in checkpoint-restore, making handling of overmounted/unlinke=
d
> sockets much cleaner.

I have to notice, that it's not enough and doesn't solve the issue.
There should be some way how to connect/bind already existent unix=20
socket (from kernel, at least), because socket can be created in user s=
pace.
And this way (sock operation or whatever) have to provide an ability to=
=20
lookup UNIX socket starting from specified root to support containers.

>
>> 	-hpa
> Thanks,
> Pavel
>
