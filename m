From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 5 May 2010 23:53:15 +0200
Message-ID: <201005052353.16544.arnd@arndb.de>
References: <20100504230225.GP8323@vmware.com> <201005052209.48465.arnd@arndb.de> <201005051336.32712.dtor@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	Pankaj Thakkar <pthakkar@vmware.com>,
	Christoph Hellwig <hch@infradead.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dmitry Torokhov <dtor@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201005051336.32712.dtor@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 05 May 2010 22:36:31 Dmitry Torokhov wrote:
> 
> On Wednesday 05 May 2010 01:09:48 pm Arnd Bergmann wrote:
> > > > If you have any interesting in developing this further, do:
> > > > 
> > > >  (1) move the limited VF drivers directly into the kernel tree,
> > > >      talk to them through a normal ops vector
> > > 
> > > [PT] This assumes that all the VF drivers would always be available.
> > > Also we have to support windows and our current design supports it
> > > nicely in an OS agnostic manner.
> > 
> > Your approach assumes that the plugin is always available, which has
> > exactly the same implications.
> 
> Since plugin[s] are carried by the host they are indeed always
> available.

But what makes you think that you can build code that can be linked
into arbitrary future kernel versions? The kernel does not define any
calling conventions that are stable across multiple versions or
configurations. For example, you'd have to provide different binaries
for each combination of

- 32/64 bit code
- gcc -mregparm=?
- lockdep
- tracepoints
- stackcheck
- NOMMU
- highmem
- whatever new gets merged

If you build the plugins only for specific versions of "enterprise" Linux
kernels, the code becomes really hard to debug and maintain.
If you wrap everything in your own version of the existing interfaces, your
code gets bloated to the point of being unmaintainable.

So I have to correct myself: this is very different from assuming the
driver is available in the guest, it's actually much worse.

	Arnd
