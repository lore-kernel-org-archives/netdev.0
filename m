From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Wed, 30 Oct 2013 10:27:30 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73C2@saturn3.aculab.com>
References: 20131029202644.GB32389@localhost.localdomain <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Ingo Molnar" <mingo@kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Doug Ledford" <dledford@redhat.com>,
	"Neil Horman" <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The parallel ALU design of this patch seems OK at first glance, but it means
> that two parallel operations are both trying to set/clear both the overflow
> and carry flags of the EFLAGS register of the *CPU* (not the ALU).  So, either
> some CPU in the past had a set of overflow/carry flags per ALU and did some
> sort of magic to make sure that the last state of those flags across multiple
> ALUs that might have been used in parallelizing work were always in the CPU's
> logical EFLAGS register, or the CPU has a buggy microcode that allowed two
> ALUs to operate on data at the same time in situations where they would
> potentially stomp on the carry/overflow flags of the other ALUs operations.

IIRC x86 cpu treat the (arithmetic) flags register as a single entity.
So an instruction that only changes some of the flags is dependant
on any previous instruction that changes any flags.
OTOH it the instruction writes all of the flags then it doesn't
have to wait for the earlier instruction to complete.

This is problematic for the ADC chain in the IP checksum.
I did once try to use the SSE instructions to sum 16bit
fields into multiple 32bit registers.

	David
