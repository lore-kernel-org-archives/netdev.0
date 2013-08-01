From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH V2 3/3] ethernet: Convert mac address uses of 6 to ETH_ALEN
Date: Thu, 1 Aug 2013 14:24:32 -0700
Message-ID: <CAOesGMhf-2KE1B8_4CGJADCG=ceDFRrDbhTnA56kXYPWoKTScg@mail.gmail.com>
References: <20130801205817.GJ23006@n2100.arm.linux.org.uk>
	<1375391087.2034.82.camel@joe-AO722>
	<20130801210618.GK23006@n2100.arm.linux.org.uk>
	<20130801.141016.1475274289112004539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Joe Perches <joe@perches.com>, Sam Creasey <sammy@sammy.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	ZongShun Wan <mcuos.com@gmail.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Network Development <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Don Fry <pcnet32@frontier.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Andrew Gallatin <gallatin@myri.com>, linux-driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130801.141016.1475274289112004539.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 1, 2013 at 2:10 PM, David Miller <davem@davemloft.net> wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Thu, 1 Aug 2013 22:06:18 +0100
>
>> On Thu, Aug 01, 2013 at 02:04:47PM -0700, Joe Perches wrote:
>>> On Thu, 2013-08-01 at 21:58 +0100, Russell King - ARM Linux wrote:
>>> > This seems rather obscure - I mean, it's not obvious to driver authors
>>> > that should be the case.  Would it not be better to make this a little
>>> > more obvious somehow?  Maybe __aligned(2) against mac_addr?  Or
>>> > maybe have a debugging check for it?
>>>
>>> That'd be for David Miller (cc'd).
>>>
>>> I believe he's argued in the past that any alignment check
>>> for mac addresses was unnecessary.
>>>
>>> For all I know it really might not matter because pasemi
>>> can successfully dereference a ushort against an odd char
>>> pointer.
>>>
>>> I just noticed it and thought it'd be better moved.
>>
>> As can ARM too for years now - either in hardware or via fixup for
>> kernel code.
>
> But probably not a good idea if it's done in a fast path.

This particular driver is for the PA Semi chips, and I very much doubt
that compatible hardware will ever show up anywhere else; they're
fairly dependent on the I/O architecture of the chip and Apple has not
brought those aspects forward in their ARM chips, as far as I know.

So, you might as well leave the code alone for now. It's not used on
fast path, and the system definitely handles unaligned accesses for
this -- it has for years already.


-Olof
