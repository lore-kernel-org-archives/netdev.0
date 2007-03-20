From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 08:09:46 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, akpm@linux-foundation.org,
   virtualization@lists.osdl.org, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, chrisw@sous-sol.org, Andi Kleen <ak@muc.de>,
   "Eric W. Biederman" <ebiederm@xmission.com>, anthony@codemonkey.ws,
   mingo@elte.hu, David Miller <davem@davemloft.net>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <45FF770C.7050301@goop.org>
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



On Mon, 19 Mar 2007, Jeremy Fitzhardinge wrote:
>
> Zachary Amsden wrote:
> > For VMI, the default clobber was "cc", and you need a way to allow at
> > least that, because saving and restoring flags is too expensive on x86.
> =

> According to lore (Andi, I think), asm() always clobbers cc. =


On x86, yes. Practically any instruction will clobber cc anyway, so it's =

the default.

Although the gcc guys have occasionally been suggesting we should set it =

in our asms.

> Actually, it still does need a temp register.  The sequence for cli is:
> =

>     mov %fs:xen_vcpu, %eax
>     movb $1,1(%eax)

We should just do this natively. There's been several tests over the years =

saying that it's much more efficient to do sti/cli as a simple store, and =

handling the "oops, we got an interrupt while interrupts were disabled" as =

a special case.

I have this dim memory that ARM has done it that way for a long time =

because it's so expensive to do a "real" cli/sti.

And I think -rt does it for other reasons. It's just more flexible.

		Linus
