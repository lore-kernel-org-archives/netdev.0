From: Zachary Amsden <zach@vmware.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Mon, 19 Mar 2007 17:23:31 -0800
Message-ID: <45FF3793.5050308@vmware.com>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de> <45FD619D.6030402@goop.org> <20070318170414.GB45869@muc.de> <45FD76E6.4060907@goop.org> <20070318193030.GB71548@muc.de> <45FDCF52.4000805@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, David Miller <davem@davemloft.net>,
	rusty@rustcorp.com.au, mingo@elte.hu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, chrisw@sous-sol.org,
	anthony@codemonkey.ws, torvalds@linux-foundation.org,
	netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:56799 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965655AbXCTBXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 21:23:32 -0400
In-Reply-To: <45FDCF52.4000805@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> For example, say we wanted to put a general call for sti into entry.S,
> where its expected it won't touch any registers.  In that case, we'd
> have a sequence like:
>
>     push %eax
>     push %ecx
>     push %edx
>     call paravirt_cli
>     pop %edx
>     pop %ecx
>     pop %eax
>       
>
> If we parse the relocs, then we'd find the reference to paravirt_cli. 
> If we look at the byte before and see 0xe8, then we can see if its a
> call.  If we then work out in each direction and see matched push/pops,
> then we know what registers can be trashed in the call.  This also
> allows us to determine the callsite size, and therefore how much space
> we need for inlining.
>   

No, that is a very dangerous suggestion.  You absolutely *cannot* do 
this safely without explicitly marking the start EIP of this code.  You 
*must* use metadata to do that.  It is never safe to disassemble 
backwards or "rewind" EIP for x86 code.

Zach
