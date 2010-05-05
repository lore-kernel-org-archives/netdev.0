From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 5 May 2010 15:05:37 -0700
Message-ID: <89E2752CFA8EC044846EB8499819134102AF2896F5@EXCH-MBX-4.vmware.com>
References: <20100504230225.GP8323@vmware.com>
	<201005052209.48465.arnd@arndb.de>	<201005051336.32712.dtor@vmware.com>
 <201005052353.16544.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Christoph Hellwig <hch@infradead.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	Pankaj Thakkar <pthakkar@vmware.com>
To: Arnd Bergmann <arnd@arndb.de>, Dmitry Torokhov <dtor@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:58394 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751145Ab0EEWFj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 18:05:39 -0400
In-Reply-To: <201005052353.16544.arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-
> bounces@vmware.com] On Behalf Of Arnd Bergmann
> Sent: Wednesday, May 05, 2010 2:53 PM
> To: Dmitry Torokhov
> Cc: Christoph Hellwig; pv-drivers@vmware.com; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org; virtualization@lists.linux-
> foundation.org; Pankaj Thakkar
> Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for
> vmxnet3
> 
> On Wednesday 05 May 2010 22:36:31 Dmitry Torokhov wrote:
> >
> > On Wednesday 05 May 2010 01:09:48 pm Arnd Bergmann wrote:
> > > > > If you have any interesting in developing this further, do:
> > > > >
> > > > >  (1) move the limited VF drivers directly into the kernel tree,
> > > > >      talk to them through a normal ops vector
> > > >
> > > > [PT] This assumes that all the VF drivers would always be
> available.
> > > > Also we have to support windows and our current design supports
> it
> > > > nicely in an OS agnostic manner.
> > >
> > > Your approach assumes that the plugin is always available, which
> has
> > > exactly the same implications.
> >
> > Since plugin[s] are carried by the host they are indeed always
> > available.
> 
> But what makes you think that you can build code that can be linked
> into arbitrary future kernel versions? The kernel does not define any
> calling conventions that are stable across multiple versions or
> configurations. For example, you'd have to provide different binaries
> for each combination of


The plugin image is not linked against Linux kernel. It is OS agnostic infact (Eg. same plugin works for Linux and Windows VMs)
Plugin is built against the shell API interface. It is loaded by hypervisor in a set of pages provided by shell. Guest OS specific tasks (like allocation of pages for plugin to load) are handled by shell and this is the one which will be upstreamed in Linux kernel. Maintenance of shell is the same as for any other driver currently existing in Linux kernel.


->Shreyas


> 
> - 32/64 bit code
> - gcc -mregparm=?
> - lockdep
> - tracepoints
> - stackcheck
> - NOMMU
> - highmem
> - whatever new gets merged
> 
> If you build the plugins only for specific versions of "enterprise"
> Linux
> kernels, the code becomes really hard to debug and maintain.
> If you wrap everything in your own version of the existing interfaces,
> your
> code gets bloated to the point of being unmaintainable.
> 
> So I have to correct myself: this is very different from assuming the
> driver is available in the guest, it's actually much worse.
> 
> 	Arnd
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
