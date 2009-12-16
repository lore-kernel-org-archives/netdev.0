From: Chetan Loke <chetanloke@gmail.com>
Subject: Re: Irq architecture for multi-core network driver.
Date: Wed, 16 Dec 2009 17:08:11 -0500
Message-ID: <b2f3590f0912161408u73947f6fx6902ebef927caf94@mail.gmail.com>
References: <4AE0D14B.1070307@caviumnetworks.com> <4AE0D72A.4090607@nortel.com>
	 <4AE0DB98.1000101@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips <linux-mips@linux-mips.org>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935800AbZLPWIR@vger.kernel.org>
In-Reply-To: <4AE0DB98.1000101@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>
>> Does your hardware do flow-based queues? =C2=A0In this model you hav=
e
>> multiple rx queues and the hardware hashes incoming packets to a sin=
gle
>> queue based on the addresses, ports, etc. This ensures that all the
>> packets of a single connection always get processed in the order the=
y
>> arrived at the net device.
>>
>
> Indeed, this is exactly what we have.
>
>
>> Typically in this model you have as many interrupts as queues
>> (presumably 16 in your case). =C2=A0Each queue is assigned an interr=
upt and
>> that interrupt is affined to a single core.
>

> Certainly this is one mode of operation that should be supported, but=
 I
> would also like to be able to go for raw throughput and have as many =
cores
> as possible reading from a single queue (like I currently have).
>
Well, you could let the NIC firmware(f/w) handle this. The f/w would
know which interrupt was just injected recently.In other words it
would have a history of which CPU's would be available. So if some
previously interrupted CPU isn't making good progress then the
firmware should route the incoming response packets to a different
queue. This way some other CPU will pick it up.


> David Daney
> --
Chetan Loke
