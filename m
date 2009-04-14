From: "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Subject: Re: usb_mon oops Re: tcpdump crashes 2.6.29.1 (and 2.6.29-rc5)
Date: Tue, 14 Apr 2009 09:38:47 -0400
Message-ID: <18916.37351.872568.757026@stoffel.org>
References: <18906.49779.243047.207639@stoffel.org>
	<20090407120022.GA6519@ff.dom.local>
	<18907.28788.965069.573489@stoffel.org>
	<20090407130403.e0061a8d.zaitcev@redhat.com>
	<18908.42166.404232.721757@stoffel.org>
	<20090408232344.afed8103.zaitcev@redhat.com>
	<18909.65347.234817.29689@stoffel.org>
	<20090413174105.b03a1f19.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090413174105.b03a1f19.zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>>>> "Pete" == Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

Pete> On Thu, 9 Apr 2009 09:59:31 -0400, "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org> wrote:
>> Here's a dmesg of bootup:

>> [    0.000000] Linux version 2.6.29.1 (john@sail) (gcc version 4.3.3 (Ubuntu 4.3.3-5ubuntu4) ) #24 SMP PREEMPT Tue Apr 7 11:30:52 EDT 2009
>> [    0.000999] Checking aperture...
>> [    0.000999] No AGP bridge found
>> [    0.000999] Node 0: aperture @ 20000000 size 32 MB
>> [    0.000999] Aperture pointing to e820 RAM. Ignoring.
>> [    0.000999] Your BIOS doesn't leave a aperture memory hole
>> [    0.000999] Please enable the IOMMU option in the BIOS setup
>> [    0.000999] This costs you 64 MB of RAM
>> [    0.000999] Mapping aperture over 65536 KB of RAM @ 20000000

>> [ 1396.271782] BUG: unable to handle kernel paging request at ffff880020a15cc0

Pete> So 20a15000 is in the aperture. Oh well, I screwed up. I meant
Pete> to check for this back in 2006 but forgot, and miraclously it
Pete> worked until now.

Pete> Here's the problem:

Pete> 	pg = phys_to_page(dma_addr);
Pete> 	map = kmap_atomic(pg, KM_IRQ0);
Pete> 	offset = mon_copy_to_buff(rp, offset, map + page_off, step_len);
Pete> 	kunmap_atomic(map, KM_IRQ0);

Pete> Obviously we don't want the page that's overlayed by the
Pete> aperture, but the page where IOMMU is pointing.

Thanks for finding this!  I was working on getting 2.6.25 built and
running, but it hates my Forcedeth ethernet ports and won't bring them
up, which complicated testing immensely.  It's tough when your home
directory is on NFS and the network is down...

I'm happy to test any patches you have.

Thanks,
John

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
