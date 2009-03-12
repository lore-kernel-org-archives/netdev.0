From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 19:46:24 +1030
Message-ID: <200903121946.24847.rusty@rustcorp.com.au>
References: <1236772642-12705-1-git-send-email-pktoss@gmail.com> <200903121759.31024.rusty@rustcorp.com.au> <1295ed070903120044s63b4da71i68add51703952d0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pantelis Koukousoulas <pktoss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57500 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835AbZCLJQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 05:16:30 -0400
In-Reply-To: <1295ed070903120044s63b4da71i68add51703952d0f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 12 March 2009 18:14:44 Pantelis Koukousoulas wrote:
> On Thu, Mar 12, 2009 at 9:29 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> > On Wednesday 11 March 2009 22:27:22 Pantelis Koukousoulas wrote:
> >> For now the semantics are simple: There is always carrier.
> >>
> >> This allows a seamless experience with e.g., qemu/kvm
> >> where NetworkManager just configures and sets up
> >> everything automagically.
> >
> > So, NetworkManager ignores the device because it doesn't support
> > carrier detection?
> 
> It doesn't ignore it, it just doesn't enable it by default, like it does for
> those that do report carrier.
> 
> But the user experience is that on real hardware you just boot a livecd
> and see your network "just working" (and the familiar icon with the 2
> computers indicating that), while under e.g., KVM/virtio you get
> non-working network / an icon with a red X and you have to
> figure out to left click on it and select eth0 to get things to work.
> 
> Some newer versions of NetworkManager seem to assume that
> if no carrier detection is supported then carrier is on by default
> so it should work for those, but that assumption seems like
> a worse hack than this patch :)

No, that's absolutely sane behavior, the previous was buggy.  If a network
doesn't support carrier, you shouldn't look for it.

Since they've fixed this in Network Manager, I'm not tempted to lie about it
in the driver (though the distributions might choose to).

Rusty.
