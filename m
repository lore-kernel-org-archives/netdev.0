From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: add suspend_halted module param
Date: Wed, 26 Feb 2014 11:35:09 -0800
Message-ID: <CAGVrzcb5k1JUPo0kvMdPJLCkWHb9qfHfDif08ud5ydKiKBwdHQ@mail.gmail.com>
References: <1393174719-20806-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <20140224191554.GC29288@lunn.ch> <530D1B7C.2090506@gmail.com>
 <20140226182117.GB14907@lunn.ch> <CAGVrzcYUfq84ryVET9qNJvyFCnhFdU4c0fOHbNN4eE8_w6qsAQ@mail.gmail.com>
 <20140226191009.GC14907@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140226191009.GC14907@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-02-26 11:10 GMT-08:00 Andrew Lunn <andrew@lunn.ch>:
>> > As to the comment from davem about not using a kernel parameter. How
>> > about turning it all around. Put a boolean parameter into DT PHY node
>> > to indicate when it is safe to power down an idle phy?
>>
>> Ah ah, nice try, but I do not think this belongs in DT, this is purely
>> a software issue here, powering up/down the PHY itself works as
>> expected.
>>
>> How about we have this knob a sysfs parameter? This should be easy
>> enough to tweak at runtime and debug in case thing go wrong.
>
> With a kernel parameter i can place it into the bootargs of the chosen
> node in DT. Solves the problem for everybody with a QNAP box. Same
> goes for topkick and any other board which has a broken u-boot. A
> sysfs parameter needs setting from user space, so it is not something
> we can solve within the kernel.

David objected to a module parameter, a kernel parameter is not too
different right?

The only case we need to handle is when the interface is brought down,
suspend_halted=true will also power down the PHY, you reboot into
u-boot, and you attempt a network boot right after that, in that case
the PHY interface is still powered down and this does not work.

That could be worked around by putting the interface up again before
you reboot into u-boot right, that specific logic being gated by
reading the board model. Agreed, you need to duplicate that workaround
in all affected user-space....
-- 
Florian
