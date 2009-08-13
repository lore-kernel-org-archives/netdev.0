From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/3] security: introducing security_request_module
Date: Thu, 13 Aug 2009 12:54:05 -0500
Message-ID: <20090813175405.GA6824@us.ibm.com>
References: <20090813134451.29186.41664.stgit@paris.rdu.redhat.com> <20090813134457.29186.7182.stgit@paris.rdu.redhat.com> <20090813140306.GC30731@us.ibm.com> <1250177334.2182.88.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	sds@tycho.nsa.gov, davem@davemloft.net,
	shemminger@linux-foundation.org, kees@ubuntu.com,
	morgan@kernel.org, casey@schaufler-ca.com, dwalsh@redhat.com
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1250177334.2182.88.camel@dhcp231-106.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric Paris (eparis@redhat.com):
> On Thu, 2009-08-13 at 09:03 -0500, Serge E. Hallyn wrote:
> > Quoting Eric Paris (eparis@redhat.com):
> > > Calling request_module() will trigger a userspace upcall which will load a
> > > new module into the kernel.  This can be a dangerous event if the process
> > > able to trigger request_module() is able to control either the modprobe
> > > binary or the module binary.  This patch adds a new security hook to
> > > request_module() which can be used by an LSM to control a processes ability
> > > to call request_module().
> > 
> > Is there a specific case in which you'd want to deny this ability
> > from a real task?
> 
> qemu and any network facing daemon are all programs I don't want to be
> able to even ask the kernel to load a module.  Clearly you are right,

...  What if the network facing daemon might want to use a kernel crypto
module?  What if qemu needs the tun module loaded?

> that the best protection is done by controlling access to modprobe and
> the modules on disk (which we are working to fix vs what happened in the
> xen fb exploit I showed earlier) but stopping it from the other
> direction is, I feel, a useful defense in depth.
> 
> If they can't get modprobe called, they can't take over the system
> directly, even if they did change a module or change modprobe.  I agree
> it's not strong security as if they can change modprobe or modules they
> might be able to just wait until something else calls modprobe (next
> reboot maybe?) to take over the system.  But I'd find it very
> interesting to know that a high threat target tried to do anything which
> attempted to load a module....
> 
> -Eric
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
