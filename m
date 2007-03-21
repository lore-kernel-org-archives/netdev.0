From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 19:15:15 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703201912270.6730@woody.linux-foundation.org>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de>
	<1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
	<1174348905.11680.54.camel@localhost.localdomain>
	<45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>
	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
	<m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
	<46000C7E.4070001@goop.org> <46005B89.5070301@vmware.com>
	<Pine.LNX.4.64.0703201715470.6730@woody.linux-foundation.org>
	<46009E42.30400@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, akpm@linux-foundation.org,
   virtualization@lists.osdl.org, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, chrisw@sous-sol.org, Andi Kleen <ak@muc.de>,
   "Eric W. Biederman" <ebiederm@xmission.com>, anthony@codemonkey.ws,
   mingo@elte.hu, David Miller <davem@davemloft.net>
To: Zachary Amsden <zach@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <46009E42.30400@vmware.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Tue, 20 Mar 2007, Zachary Amsden wrote:
> =

> Actually, I was thinking the irq handlers would just not mess around with
> eflags on the stack, just call the chip to ack the interrupt and re-enable
> hardware interrupts when they left, since that is free anyway with the ir=
et.

No can do. Think level-triggered. You *need* to disable the interrupt, and =

disabling it at the CPU is the easiest approach. Even so, you need to =

worry about SMP and screaming interrupts at all CPU's, but if you don't =

ack it to the IO-APIC until later, that should be ok (alternatively, you =

need to just mask-and-ack the irq controller).

> Maybe leaving irqs disabled is better.

One of the advantages of doing that is that you only ever have a queue of =

one single entry, which then makes it easier to do the replay.

		Linus
