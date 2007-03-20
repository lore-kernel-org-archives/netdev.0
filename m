From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Mon, 19 Mar 2007 22:54:20 -0700
Message-ID: <45FF770C.7050301@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net>	 <45FB005D.9060809@goop.org>	 <1174127638.8897.75.camel@localhost.localdomain>	 <20070318.003309.71088169.davem@davemloft.net>	 <20070318120814.GA45869@muc.de>	 <1174272469.11680.23.camel@localhost.localdomain>	 <m1648xxf93.fsf@ebiederm.dsl.xmission.com>	 <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andi Kleen <ak@muc.de>, David Miller <davem@davemloft.net>,
	mingo@elte.hu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, chrisw@sous-sol.org,
	anthony@codemonkey.ws, netdev@vger.kernel.org
To: Zachary Amsden <zach@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:42063 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752177AbXCTFyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 01:54:25 -0400
In-Reply-To: <45FF4043.4000805@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zachary Amsden wrote:
> For VMI, the default clobber was "cc", and you need a way to allow at
> least that, because saving and restoring flags is too expensive on x86.

According to lore (Andi, I think), asm() always clobbers cc. 

> I still don't think this was a good trade.  The primary motivation for
> clobbering %eax was that Xen wanted a free register to use for
> computing the offset into the shared data in the case of SMP
> preemptible kernels.  Xen no longer needs such a register, they can
> use the PDA offset instead.  And it does hurt native performance by
> unconditionally stealing a register in the four most commonly invoked
> paravirt-ops code sequences.

Actually, it still does need a temp register.  The sequence for cli is:

    mov %fs:xen_vcpu, %eax
    movb $1,1(%eax)

At some point I hope to move the vcpu structure directly into the
pda/percpu variables, at which point it will need no temps.

    J
