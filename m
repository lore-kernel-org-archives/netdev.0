From: "Daniel P. Berrange" <berrange@redhat.com>
Subject: Re: [libvirt-users] libvirt & virtio_net - host.freeze@reset.domain
Date: Wed, 3 Jul 2013 12:43:28 +0100
Message-ID: <20130703114327.GW2778@redhat.com>
References: <51D2B8A1.9050002@gmail.com>
Reply-To: "Daniel P. Berrange" <berrange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: libvir-list@redhat.com, netdev@vger.kernel.org,
	libvirt-users@redhat.com
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7341 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503Ab3GCLne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jul 2013 07:43:34 -0400
Content-Disposition: inline
In-Reply-To: <51D2B8A1.9050002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 02, 2013 at 01:25:21PM +0200, poma wrote:
> Hello people,
> 
> libvirtd (libvirt) 1.0.5.2
> virsh 1.0.5.2
> virt-manager 0.10.0
> 
> Host:
> Linux localhost 3.9.8-300.fc19.x86_64 #1 SMP Thu Jun 27 19:24:23 UTC
> 2013 x86_64 x86_64 x86_64 GNU/Linux
> Guest1:
> Linux localhost 3.9.8-300.fc19.i686.PAE #1 SMP Thu Jun 27 19:29:30 UTC
> 2013 i686 (none)
> Guest2:
> Linux localhost 3.9.8-300.fc19.x86_64 #1 SMP Thu Jun 27 19:24:23 UTC
> 2013 x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> Virtual NIC - source & model:
> macvtap/NAT/bridge & virtio(virtio_net)
> 
> Host freeze at "virsh reset <domain>" or "virt-manager - Force Reset"
> Need kernel.sysrq or power reset.

I don't believe this is a libvirt issue - the 'virsh reset' command
will issue the 'system_reset' QEMU monitor command. This in turn
does an immediate reset of the guest CPUs/machine.

Even if QEMU is doing the wrong thing, the kernel should obviously
never freeze/crash in this way - it should be robust against a
malicious QEMU process.

You should probably send this message to the main QEMU and/or KVM
mailing lists so that it comes to the attention of people who are
more familiar with QEMU + virtio-net


Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
