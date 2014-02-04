From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration
 from device tree
Date: Tue, 4 Feb 2014 14:48:15 -0800
Message-ID: <CAGVrzcbwiVCj0oETXms6ek+QG13BEbgydLzUEckuGFOhSx0iXQ@mail.gmail.com>
References: <7510122.cayuQ6qt8r@wuerfel> <1389999459-9483-1-git-send-email-matthew.garrett@nebula.com>
 <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com> <1391550040.3003.28.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matthew Garrett <matthew.garrett@nebula.com>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kishon Vijay Abraham I <kishon@ti.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391550040.3003.28.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-02-04 Ben Hutchings <ben@decadent.org.uk>:
> On Tue, 2014-02-04 at 12:39 -0800, Florian Fainelli wrote:
>> 2014-01-17 Matthew Garrett <matthew.garrett@nebula.com>:
>> > Some hardware may be broken in interesting and board-specific ways, such
>> > that various bits of functionality don't work. This patch provides a
>> > mechanism for overriding mii registers during init based on the contents of
>> > the device tree data, allowing board-specific fixups without having to
>> > pollute generic code.
>>
>> It would be good to explain exactly how your hardware is broken
>> exactly. I really do not think that such a fine-grained setting where
>> you could disable, e.g: 100BaseT_Full, but allow 100BaseT_Half to
>> remain usable makes that much sense. In general, Gigabit might be
>> badly broken, but 100 and 10Mbits/sec should work fine. How about the
>> MASTER-SLAVE bit, is overriding it really required?
>
> Yes, it is entirely possible that one or other of the clock modes
> (locally generated vs recovered) is not reliable.

That one is not covered in the existing Ethernet PHY binding, okay for
handling it.

>
>> Is not a PHY fixup registered for a specific OUI the solution you are
>> looking for?
> [...]
>
> The fault is in the board, not the PHY.

What kind of fault at the board level are we talking about? Lack of
specific twisted pair wiring to the RJ-45 jack? Out of spec RXC/TXC on
a (R)GMII path? If the latter, this is going to be via vendor-specific
MII registers, and should be a good enough reason for registering a
PHY fixup. What about pad control, and Ethernet MACs specicif register
affecting the internal delays and such?
-- 
Florian
