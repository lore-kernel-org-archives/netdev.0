From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Fri, 15 May 2009 11:07:43 +0400
Message-ID: <4A0D14BF.5010409@msgid.tls.msk.ru>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com> <200905142128.58111.rusty@rustcorp.com.au> <4A0C2500.7090709@Voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Or Gerlitz <ogerlitz@Voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:49361 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754942AbZEOHHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 03:07:46 -0400
In-Reply-To: <4A0C2500.7090709@Voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz wrote:
> Rusty Russell wrote:
>> The answer is that virtio_net by default only supports 1500 
>> MTU; I've not tried larger MTUs.
> 
> Rusty,
> 
> I hoped to get some performance boost from using checksum and large-send offloads 
> as an alternative to jumbo frames. Looking in the virtio-net kernel driver, I see that the probe
> function checks if virtio_has_feature VIRTIO_NET_F_CSUM ... VIRTIO_NET_F_HOST_TSO ... and if yes
> sets the relevant bits in the NIC features mask. Looking in the virtio qemu code, I also see some offload
> related code.

A trap which I've seen before.

When compiling kvm userspace, ensure your kernel headers installed in
/usr/include has the latest if_tun.h bits, in particular the TUNSETOFFLOAD
and IFF_VNET_HDR definitions.

One solution to this is just to copy that file from kernel-2.6.29.  Or
maybe it's easier to add some -I flags to kvm compile commandline.

And one more note: I'm not sure if there's anything else needed.
Last time I was there -- it was with kvm-84 times I think, maybe
something changed since that.

/mjt
