From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] drivers: staging: lustre: lustre: include: add
 "__attribute__((packed))" for the related union
Date: Mon, 3 Feb 2014 10:05:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B772B@AcuExch.aculab.com>
References: <20140118142404.GT7444@mwanda> <52DBA3D4.3090308@gmail.com>
 <52DD0EFF.2010305@imgtec.com> <20140120123045.GV7444@mwanda>
 <52DD18A5.1090308@imgtec.com> <20140120125603.GD4815@mwanda>
 <20140120211356.GG4815@mwanda> <52DE4DA3.7090301@imgtec.com>
 <52E3A642.7010307@gmail.com> <52ECFD53.7010401@gmail.com>
 <20140203085855.GA26722@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: James Hogan <james.hogan@imgtec.com>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"andreas.dilger@intel.com" <andreas.dilger@intel.com>,
	Antonio Quartulli <antonio@meshcoding.com>,
	"Greg KH" <gregkh@linuxfoundation.org>,
	"bergwolf@gmail.com" <bergwolf@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"oleg.drokin@intel.com" <oleg.drokin@intel.com>,
	"jacques-charles.lafoucriere@cea.fr"
	<jacques-charles.lafoucriere@cea.fr>,
	"jinshan.xiong@intel.com" <jinshan.xiong@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-metag@vger.kernel.org" <linux-metag@vger.kernel.org>
To: 'Dan Carpenter' <dan.carpenter@oracle.com>,
	Chen Gang <gang.chen.5i5j@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140203085855.GA26722@mwanda>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter
> On Sat, Feb 01, 2014 at 09:57:39PM +0800, Chen Gang wrote:
> > It seems, our kernel still stick to treate 'pack' region have effect
> > with both 'align' and 'sizeof'.
> 
> It's not about packed regions.  It's about unions.  It's saying the
> sizeof() a union is a multiple of 4 unless it's packed.
> 
> union foo {
> 	short x;
> 	short y;
> };
> 
> The author intended the sizeof(union foo) to be 2 but on metag arch then
> it is 4.

The same is probably be true of: struct foo { _u16 bar; };

Architectures that define such alignment rules are a right PITA.
You either need to get the size to 2 without using 'packed', or
just not define such structures.
It is worth seeing if adding aligned(2) will change the size - I'm
not sure.

	David
