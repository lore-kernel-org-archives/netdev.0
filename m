From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Mon, 22 Aug 2011 09:54:50 +0930
Message-ID: <87hb5a5m3x.fsf@rustcorp.com.au>
References: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com> <20110819152335.GA19489@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110819152335.GA19489@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Aug 2011 18:23:35 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Sat, Aug 13, 2011 at 11:51:01AM +0300, Sasha Levin wrote:
> > The MAC of a virtio-net device is located at the first field of the device
> > specific header. This header is located at offset 20 if the device doesn't
> > support MSI-X or offset 24 if it does.
> > 
> > Current code in virtnet_probe() used to probe the MAC before checking for
> > MSI-X, which means that the read was always made from offset 20 regardless
> > of whether MSI-X in enabled or not.
> > 
> > This patch moves the MAC probe to after the detection of whether MSI-X is
> > enabled. This way the MAC will be read from offset 24 if the device indeed
> > supports MSI-X.
> > 
> > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > Cc: Michael S. Tsirkin <mst@redhat.com>
> > Cc: virtualization@lists.linux-foundation.org
> > Cc: netdev@vger.kernel.org
> > Cc: kvm@vger.kernel.org
> > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> 
> I am not sure I see a bug in virtio: the config pace layout simply
> changes as msix is enabled and disabled (and if you look at the latest
> draft, also on whether 64 bit features are enabled).
> It doesn't depend on msix capability being present in device.
> 
> The spec seems to be explicit enough:
> 	If MSI-X is enabled for the device, two additional fields immediately
> 	follow this header.
> 
> So I'm guessing the bug is in kvm tools which assume
> same layout for when msix is enabled and disabled.
> qemu-kvm seems to do the right thing so the device
> seems to get the correct mac.

So, the config space moves once MSI-X is enabled?  In which case, it
should say "ONCE MSI-X is enabled..."

Thanks,
Rusty.
