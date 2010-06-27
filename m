From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: dhclient, checksum and tap
Date: Sun, 27 Jun 2010 11:24:40 +0300
Message-ID: <20100627082439.GA8472@redhat.com>
References: <20100625151008.GA17911@redhat.com> <20100625.112152.241921019.davem@davemloft.net> <20100626211419.GA3646@redhat.com> <20100626.200320.43025947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert.xu@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20992 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184Ab0F0I3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jun 2010 04:29:43 -0400
Content-Disposition: inline
In-Reply-To: <20100626.200320.43025947.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 26, 2010 at 08:03:20PM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Sun, 27 Jun 2010 00:14:19 +0300
> 
> > On Fri, Jun 25, 2010 at 11:21:52AM -0700, David Miller wrote:
> >> We added the af_packet status as the migration path to deal with
> >> this issue in the cleanest manner possible.  Putting a new hack
> >> into the TAP driver works contrary to that goal.
> > 
> > Hmm, problem is, using the af_packets status requires
> > userspace changes, and so does not help old clients.
> > And for virt, clients might be running old kernels without this support.
> > qemu has a hack to make old guests running within qemu work.
> > I guess I can copy that hack into vhost - a bit ugly as I don't have
> > access to the original skb there, so I will have to duplcate some logic,
> > but doable.  Is this what you suggest?  OTOH if we had the workaround in
> > tap, this could replace hacks in both vhost and qemu.
> 
> If you add the TAP thing you can _never_ remove it.  Exactly for the
> same reason that the qemu thing can never be removed.  It'll always be
> needed for the sake of old guests running old stuff.
> 
> This is why I truly believe that keeping the af_packet status thing as
> the only kernel side assist is likely best in the long run.

Just to spell it out for me, you think the hack should be done
in vhost-net?

-- 
MST
