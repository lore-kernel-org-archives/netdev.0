From: Andi Kleen <ak@muc.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: 20 Mar 2007 21:02:42 +0100
Message-ID: <20070320200242.GA90774@muc.de>
References: <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org> <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org> <m1mz27sy82.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org> <20070320192818.GA87860@muc.de> <46003BF1.4090601@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Zachary Amsden <zach@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colin.muc.de ([193.149.48.1]:2391 "EHLO mail.muc.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934044AbXCTUCo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 16:02:44 -0400
Date: Tue, 20 Mar 2007 21:02:42 +0100
Content-Disposition: inline
In-Reply-To: <46003BF1.4090601@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Worth it on 32-bit.  On AMD64, probably not.  On Intel 64-bit, maybe, 
> but less important than in P4 days.

Well most of Intel 64bit is P4 -- and Intel is still shipping
millions more of them each quarter.

> This could change character completely if used at the tail of a function 
> where you now have
> 
> sti; 1: ret
> 
> Which generates an interrupt holdoff on the ret, an unusual thing to do.

Unusual yes, but I don't see how it should cause problems. Or do you
have anything specific in mind? 

Worse is probably that on K8 this case might cause a pipeline stall
if there isn't a prefix in front of the ret.

-Andi
