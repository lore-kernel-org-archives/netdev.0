From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
 paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 16:33:58 -0700
Message-ID: <46006F66.4030901@goop.org>
References: <1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
	<1174348905.11680.54.camel@localhost.localdomain>
	<45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>
	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
	<m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
	<46000C7E.4070001@goop.org> <20070320224324.GL10459@waste.org>
	<46006963.1020401@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, akpm@linux-foundation.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org, Andi Kleen <ak@muc.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	anthony@codemonkey.ws, Matt Mackall <mpm@selenic.com>,
	mingo@elte.hu, Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Zachary Amsden <zach@vmware.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <46006963.1020401@vmware.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Zachary Amsden wrote:
> I think Jeremy's idea was to have interrupt handlers leave interrupts
> disabled on exit if pda.intr_mask was set.  In which case, they would
> bypass all work and we could never get preempted.

Yes, I was worried that if we left the isr without actually handling the
interrupt, it would still be asserted and we'd just get interrupted
again.  The idea is that we avoid touching cli/sti for the common case
of no interrupts while interrupts are disabled, but we'd still need to
fall back to using them if an interrupt becomes pending.

> I don't think leaving hardware interrupts disabled for such a long
> time is good though. 

How long?  It would be no longer than now, and possibly less, wouldn't it?

    J
