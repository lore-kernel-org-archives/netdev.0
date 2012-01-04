From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v6 09/11] virtio: net: Add freeze,
	restore handlers to support S4
Date: Wed, 04 Jan 2012 13:19:47 +1030
Message-ID: <87ty4cchbo.fsf@rustcorp.com.au>
References: <cover.1324553223.git.amit.shah@redhat.com>
	<f84fa9fdc9f5629e711cbb89a2e7efbb289d72fa.1324553223.git.amit.shah@redhat.com>
	<20111229161523.GB2300@redhat.com>
	<20111230085205.GG4576@amit.redhat.com>
	<20120101114727.GC25350@redhat.com>
	<20120103170748.GE4536@amit.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-pm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Virtualization List <virtualization@lists.linux-foundation.org>
To: Amit Shah <amit.shah@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120103170748.GE4536@amit.redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Jan 2012 22:37:48 +0530, Amit Shah <amit.shah@redhat.com> wrote:
> On (Sun) 01 Jan 2012 [13:47:27], Michael S. Tsirkin wrote:
> > On Fri, Dec 30, 2011 at 03:08:19PM +0530, Amit Shah wrote:
> > > > 
> > > > > +	if (!try_fill_recv(vi, GFP_KERNEL))
> > > > > +		schedule_delayed_work(&vi->refill, 0);
> > > > 
> > > > This needs to be switched to non reentrant wq too?
> > > 
> > > Subsequent invocations could create problems?  Note that this will be
> > > the first item to be queued in the workqueue for the refill work.
> > > 
> > > 		Amit
> > 
> > See recent patches on net-next.
> > We switched other calls to a non reentrant wq so I think same
> > reasoning applies there.
> 
> There's a patch ordering issue; so this series should land after the
> -net series is merged.
> 
> Rusty, do you want me to re-spin this patch on top of yours, or is
> that something that you'll handle?

Indeed, this can't go via -net, since it needs the virtio-pci patches
which change power management.

I've changed that one line, and will post those patches for DaveM's ack.

Thanks,
Rusty.
