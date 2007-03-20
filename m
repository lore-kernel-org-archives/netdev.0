From: Zachary Amsden <zach@vmware.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Tue, 20 Mar 2007 11:54:25 -0800
Message-ID: <46003BF1.4090601@vmware.com>
References: <20070318120814.GA45869@muc.de> <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org> <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org> <m1mz27sy82.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org> <20070320192818.GA87860@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Andi Kleen <ak@muc.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:36051 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753296AbXCTTy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 15:54:26 -0400
In-Reply-To: <20070320192818.GA87860@muc.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> One thing I was pondering was to replace the expensive popfs with
>
> bt  $IF,(%rsp) 
> jnc 1f 
> sti
> 1: 
>
> But would be mostly a P4 optimization again and I'm not 100% sure it is
> worth it.
>   

Worth it on 32-bit.  On AMD64, probably not.  On Intel 64-bit, maybe, 
but less important than in P4 days.

This could change character completely if used at the tail of a function 
where you now have

sti; 1: ret

Which generates an interrupt holdoff on the ret, an unusual thing to do.

Zach
