From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] drivers: staging: lustre: lustre: include: add
 "__attribute__((packed))" for the related union
Date: Mon, 3 Feb 2014 10:35:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B777A@AcuExch.aculab.com>
References: <20140118142404.GT7444@mwanda> <52DBA3D4.3090308@gmail.com>
 <52DD0EFF.2010305@imgtec.com> <20140120123045.GV7444@mwanda>
 <52DD18A5.1090308@imgtec.com> <20140120125603.GD4815@mwanda>
 <20140120211356.GG4815@mwanda> <52DE4DA3.7090301@imgtec.com>
 <52E3A642.7010307@gmail.com> <52ECFD53.7010401@gmail.com>
 <20140203085855.GA26722@mwanda>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B772B@AcuExch.aculab.com>
 <52EF6DCC.6040807@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Dan Carpenter' <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org" <devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>,
	"andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>,
	"Greg KH" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"bergwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <bergwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"jacques-charles.lafoucriere-KCE40YydGKI@public.gmane.org"
	<jacques-charles.lafoucriere-KCE40YydGKI@public.gmane.org>,
	"jinshan.xiong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <jinshan.xiong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'James Hogan' <james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52EF6DCC.6040807-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: James Hogan 
> On 03/02/14 10:05, David Laight wrote:
> > From: Dan Carpenter
> >> On Sat, Feb 01, 2014 at 09:57:39PM +0800, Chen Gang wrote:
> >>> It seems, our kernel still stick to treate 'pack' region have effect
> >>> with both 'align' and 'sizeof'.
> >>
> >> It's not about packed regions.  It's about unions.  It's saying the
> >> sizeof() a union is a multiple of 4 unless it's packed.
> >>
> >> union foo {
> >> 	short x;
> >> 	short y;
> >> };
> >>
> >> The author intended the sizeof(union foo) to be 2 but on metag arch then
> >> it is 4.
> >
> > The same is probably be true of: struct foo { _u16 bar; };
> 
> Yes indeed.
> 
> > Architectures that define such alignment rules are a right PITA.
> > You either need to get the size to 2 without using 'packed', or
> > just not define such structures.
> > It is worth seeing if adding aligned(2) will change the size - I'm
> > not sure.
> 
> __aligned(2) alone doesn't seem to have any effect on sizeof() or
> __alignof__() unless it is accompanied by __packed. x86_64 is similar in
> that respect (it just packs sanely in the first place).
> 
> Combining __packed with __aligned(2) does the trick though (__packed
> alone sets __aligned(1) which is obviously going to be suboptimal).

Compile some code for a cpu that doesn't support misaligned transfers
(probably one of sparc, arm, ppc) and see if the compiler generates a
single 16bit request or two 8 bits ones.
You don't want the compiler generating multiple byte-sized memory transfers.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-metag" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
