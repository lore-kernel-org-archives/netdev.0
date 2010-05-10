From: Pankaj Thakkar <pthakkar@vmware.com>
Subject: Re: RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Mon, 10 May 2010 13:46:43 -0700
Message-ID: <20100510204643.GH25364@vmware.com>
References: <20100504230225.GP8323@vmware.com>
 <4BE1B217.80600@redhat.com>
 <20100505194417.GV8323@vmware.com>
 <4BE284CE.7010808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:33578 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932175Ab0EJUqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:46:44 -0400
Content-Disposition: inline
In-Reply-To: <4BE284CE.7010808@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 06, 2010 at 01:58:54AM -0700, Avi Kivity wrote:
> > We don't pass the whole VF to the guest. Only the BAR which is responsible for
> > TX/RX/intr is mapped into guest space.
> 
> Does the SR/IOV spec guarantee that you will have such a separation?

No. This is a guideline which we provided to IHVs and would have to be enforced
through testing/certification.

> How can you unmap the VF without guest cooperation?  If you're executing 
> Plugin code, you can't yank anything out.

In our Kawela plugin we don't have any reads from the memory space at all.
Hence you can yank the VF anytime (the code loaded in the guest address space
will keep on executing). Even if there were reads we can map the memory
pages to a NULL page and return 0xffffffff so that the plugin can detect this
and return an error to the shell. Remember there are no control operations in
the plugin and the code is really small (about 1k lines compared to 5k lines in
the full VF driver).

> 
> Are plugins executed with preemption/interrupts disabled?

Depends on the model. Today the plugin code for checking the TX/RX rings runs
in the deferred napi context.

> What ISAs do those plugins support?

x86 and x64.

Thanks,

-pankaj

