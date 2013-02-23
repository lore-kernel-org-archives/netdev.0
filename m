From: Paul Moore <pmoore@redhat.com>
Subject: Re: AF_VSOCK and the LSMs
Date: Fri, 22 Feb 2013 19:27:25 -0500
Message-ID: <2331260.82H25I6ITJ@sifl>
References: <1803195.0cVPJuGAEx@sifl> <888679886.3769933.1361573683299.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>
To: Andy King <acking@vmware.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <888679886.3769933.1361573683299.JavaMail.root@vmware.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, February 22, 2013 02:54:43 PM Andy King wrote:
> Hi Paul,
> 
> > to see if anyone had any strong feelings on this approach (either good or
> > bad).  Here is what I am proposing, and currently working on ...
> > 
> > * Add a LSM secid/blob to the vmci_datagram struct
> 
> I think perhaps this is the wrong layer at which to embed this.  Think
> of that structure as an ethernet header, with VMCI being ethernet; it's
> what the device (and the hypervisor and peer) understand.  So this
> really cannot be changed.

Hmmm, so can VMware/VMCI-enabled guests send vmci_datagram packets directly 
into the kernel?  It isn't wrapped by things like AF_VSOCK?  If that is the 
case, then yes, we'll probably need to add a thin wrapper struct to carry the 
security label; similar to the control packets but not quite, as we have data 
to deal with unlike the control packets.  However, if vmci_datagram is an 
internal only structure, why not add the extra field?

Either way, we should be able to work around this, it would just be cleaner if 
we could add it to the datagram directly.

> It's also not entirely clear to me how this will work in a heterogeneous
> environments.  What if there's a Linux guest running on a Windows host,
> or vice-versa?

I maybe missing something here, but VMCI never leaves the physical host system 
correct?  It doesn't get tunneled over some external network does it?

Assuming it stays on the physical host system then we don't really care about 
a Windows host in this context do we?  From a guests point of view it doesn't 
really matter, the kernel handles all of the labeling and access control; the 
guests create their AF_VSOCKS as they normally would.

> I'll take a closer read at the rest of your mail, but I think we need to
> address the above first.

I think there is some confusion about VMCI - which is almost surely on my end 
- and what I'm trying to accomplish with the labeling, perhaps by answering 
the above questions you can help me gain a better understanding and we can 
sort things out.

Thanks.

-- 
paul moore
security and virtualization @ redhat

