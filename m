From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Thu, 14 May 2009 17:04:48 +0300
Message-ID: <4A0C2500.7090709@Voltaire.com>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com> <200905142128.58111.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:17335 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752412AbZENOE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 10:04:56 -0400
In-Reply-To: <200905142128.58111.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> The answer is that virtio_net by default only supports 1500 
> MTU; I've not tried larger MTUs.

Rusty,

I hoped to get some performance boost from using checksum and large-send offloads 
as an alternative to jumbo frames. Looking in the virtio-net kernel driver, I see that the probe
function checks if virtio_has_feature VIRTIO_NET_F_CSUM ... VIRTIO_NET_F_HOST_TSO ... and if yes
sets the relevant bits in the NIC features mask. Looking in the virtio qemu code, I also see some offload
related code.

In my case, both the guest and the host run 2.6.29.1 and I use ethX (igb based) -- bridge -- tapY <--> qemu configuration, where qemu is the one provided by kvm latest release (84).  Now, the virtio guest NIC doesn't expose any features (its mask being 0x20 - only highdma). Anything I can do to have offloads support for my virtio environment? 

Or.
