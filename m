From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Fri, 06 Apr 2007 11:02:37 +1000
Message-ID: <1175821357.12230.642.camel@localhost.localdomain>
References: <4613B438.60107@codemonkey.ws> <4613B89F.8090806@qumranet.com>
	 <4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com>
	 <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com>
	 <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>
	 <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>
	 <20070404212103.GA19026@elte.hu>
	 <1175728768.12230.593.camel@localhost.localdomain>
	 <4614A294.3000607@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47424 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992834AbXDFBC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 21:02:57 -0400
In-Reply-To: <4614A294.3000607@qumranet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-04-05 at 10:17 +0300, Avi Kivity wrote:
> Rusty Russell wrote:
> > You didn't quote Anthony's point about "it's more about there not being
> > good enough userspace interfaces to do network IO."
> >
> > It's easier to write a kernel-space network driver, but it's not
> > obviously the right thing to do until we can show that an efficient
> > packet-level userspace interface isn't possible.  I don't think that's
> > been done, and it would be interesting to try.
> >   
> 
> In the case of networking, the copyful interfaces on receive are driven 
> by the hardware not knowing how to split the header from the data.  On 
> transmit I agree, it could be made copyless from userspace (somthing 
> like sendfilev, only not file oriented).

Hi Avi,

	I don't think you've thought about this very hard.  The receive copy is
completely independent with whether the packet is going to the guest via
a kernel driver or via userspace, so not relevant.

	And if all packets from the card are going to the guest, you can
deliver directly.  Userspace or kernel, no difference.

	And we have a "sendfilev not file oriented": it's called "writev" 8)

	An in-kernel driver can avoid system call overhead and page references.
But a better tap device helps more than just KVM.

Rusty.


