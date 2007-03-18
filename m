From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Sun, 18 Mar 2007 08:58:21 -0700
Message-ID: <45FD619D.6030402@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rusty@rustcorp.com.au,
	mingo@elte.hu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, chrisw@sous-sol.org,
	zach@vmware.com, anthony@codemonkey.ws,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: Andi Kleen <ak@muc.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:32836 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932465AbXCRP6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2007 11:58:22 -0400
In-Reply-To: <20070318120814.GA45869@muc.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>> The idea is _NOT_ that you go look for references to the paravirt_ops
>> members structure, that would be stupid and you wouldn't be able to
>> use the most efficient addressing mode on a given cpu, you'd be
>> patching up indirect calls and crap like that.  Just say no...
>>     
>
> That wouldn't handle inlines though. At least some of the current
> paravirtops like cli/sti are critical enough to require inlining.
>   

You could special-case it in the thing handling the relocs; if you're
relocating to point to a function which you have an inline substitution,
then inline.

The bigger problem is that you don't know what registers you can
clobber.  For the pv_ops in hand-written asm, that a big pain.  The code
either has to assume the worst, or the "relocator" has to do something
more sophisticated (like look for push/pop pairs surrounding the call,
perhaps?).

    J
