From: Andy King <acking@vmware.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Mon, 4 Feb 2013 15:41:35 -0800 (PST)
Message-ID: <1910061949.2175231.1360021295545.JavaMail.root@vmware.com>
References: <510B78E6.3000602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <510B78E6.3000602@redhat.com>
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

Hi Gerd,

> From my side the minimum requirement is to have
> vsock_(un)register_transport calls available, so it is possible to
> write a virtio transport module without having to patch vsock code
> to hook it up.

We've done exactly that.  It's now split into two separate modules,
with the core module offering precisely the calls you've requested.
All transport code is now its own module.  So now you should be
able to add a vsock_transport_virtio module, which can register
with the core.

> >>> +	struct {
> >>> +		/* For DGRAMs. */
> >>> +		struct vmci_handle dg_handle;
> >>
> >> Yep, should be a pointer where transports can hook in their
> >> private
> >> data.
> > 
> > I'm fixing this.
> 
> Yes, please, that is needed too to get started with virtio support.

Fixed: it's now a void * in the core socket structure.

I believe it's now at the point where you can start working on the
virtio transport, and we'll address API issues as they arise and
refine it as necessary.  So please take one last look and let us
know what you think; hopefully we can make the current merge window :)

Thanks!
- Andy
