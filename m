From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Sat, 25 Jun 2016 08:56:07 -0700
Message-ID: <CALx6S37UHUWP-+LFvNtWn=oR_ucB3_EK2Bejr3pDsMOd1K8Qfw@mail.gmail.com>
References: <CALx6S37+o2=Lqzxu_U4QiSvqnq8CjEq5uSpbKVfFfo8r5qD+6g@mail.gmail.com>
 <20160621.042918.1782717212289281861.davem@davemloft.net> <CAPshTCgCVs5i1QyLeNPzw2W3X5+r_=5Hw1HOnD+cBsBQBRN35g@mail.gmail.com>
 <20160622.152307.631430680793264716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jerry Chu <hkchu@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33397 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbcFYP4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 11:56:09 -0400
Received: by mail-io0-f169.google.com with SMTP id t74so122090680ioi.0
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2016 08:56:08 -0700 (PDT)
In-Reply-To: <20160622.152307.631430680793264716.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 12:23 PM, David Miller <davem@davemloft.net> wrote:
> From: Jerry Chu <hkchu@google.com>
> Date: Tue, 21 Jun 2016 20:42:19 -0700
>
>> I don't believe TOU will lead to a proliferation of TCP
>> implementations in the userland - getting a solid TCP implementation
>> is hard.
>
> The fear isn't doing legitimate things.
>
> It's making TCP stacks that do evil stuff on purpose.
>
> Also, making proprietary TCP stacks that override the kernel one.
>
There is no "kernel one", there are many client kernels, many
different stacks on the Internet, many implementations of TCP. Some of
these are poorly engineered, years behind in technology, and otherwise
horribly insecure. There are even still people running WIndows95 for
heaven's sake! There is simply no way we can just implicitly trust
kernels to be doing the right thing. Neither is there any requirement
for us to do so, you will not find a requirement in any Internet
standard that TCP MUST be implemented in the kernel. The same
characteristics hold for middleboxes and firewalls, there are many
implementations, many don't follow standards, and the SW/FW upgrade
issue is potentially catastrophic to the Internet.  We have no
requirement and can never assume that a robust sufficient firewall is
the in the path of our packets.

Bottom line: if you're developing a business critical application on
the Internet, you cannot assume that the OSes or the network provide
adequate security; you need to take ownership of security for your
application. TOU is a step in that direction.

> And finally, here's the best part, all of the above can be done as a
> new, huge, potential attack vector for hackers.
>
I disagree that there is a new attack vector here. Yes, a malicious
program can open up an unconnected UDP socket and send to any
destination although they should not be able to spoof source address
easily. This is well known and attacks against DNS and other current
uses of UDP already exit. But, a major part of TOU is that the
transport layer header is encrypted so this makes it impossible to
inject packets into a TOU connection even if the program is able to
snoop packets on the wire. TOU is be protected against injection
attacks unlike TCP since headers are in cleartext. So the worse case
attack should be a form of SYN attack which we already have to deal
with for existing transport protocols.

Thanks,
Tom
