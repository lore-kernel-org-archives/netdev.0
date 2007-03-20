From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 09:06:15 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, virtualization@lists.osdl.org,
   netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
   David Miller <davem@davemloft.net>, chrisw@sous-sol.org,
   Andi Kleen <ak@muc.de>, anthony@codemonkey.ws, akpm@linux-foundation.org,
   mingo@elte.hu
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
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



On Tue, 20 Mar 2007, Eric W. Biederman wrote:
> =

> If that is the case.  In the normal kernel what would
> the "the oops, we got an interrupt code do?"
> I assume it would leave interrupts disabled when it returns?
> Like we currently do with the delayed disable of normal interrupts?

Yeah, disable interrupts, and set a flag that the fake "sti" can test, and =

just return without doing anything.

(You may or may not also need to do extra work to Ack the hardware =

interrupt etc, which may be irq-controller specific. Once the CPU has =

accepted the interrupt, you may not be able to just leave it dangling)

But I was throwing that out as a long-term thing. I'm not claiming it's =

trivial, but it should be doable.

		Linus
