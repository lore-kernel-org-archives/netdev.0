From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 0/4]  Allow bridge to function in non-promisc
 mode
Date: Wed, 13 Mar 2013 22:08:07 +0200
Message-ID: <20130313200807.GA9821@redhat.com>
References: <1363139126-13396-1-git-send-email-vyasevic@redhat.com>
 <473541363155743@web2d.yandex.ru>
 <51406D2D.30703@redhat.com>
 <20130313083932.6483876f@nehalam.linuxnetplumber.net>
 <51409F24.3070305@redhat.com>
 <20130313090921.05dbf6e2@nehalam.linuxnetplumber.net>
 <5140B1B3.2070205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"Oleg A. Arkhangelsky" <sysoleg@yandex.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933130Ab3CMUHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 16:07:48 -0400
Content-Disposition: inline
In-Reply-To: <5140B1B3.2070205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 01:04:51PM -0400, Vlad Yasevich wrote:
> On 03/13/2013 12:09 PM, Stephen Hemminger wrote:
> >On Wed, 13 Mar 2013 11:45:40 -0400
> >Vlad Yasevich <vyasevic@redhat.com> wrote:
> >
> >>On 03/13/2013 11:39 AM, Stephen Hemminger wrote:
> >>>On Wed, 13 Mar 2013 08:12:29 -0400
> >>>Vlad Yasevich <vyasevic@redhat.com> wrote:
> >>>
> >>>>On 03/13/2013 02:22 AM, "Oleg A. Arkhangelsky" wrote:
> >>>>>
> >>>>>
> >>>>>13.03.2013, 05:45, "Vlad Yasevich" <vyasevic@redhat.com>:
> >>>>>
> >>>>>>The series adds an ability for the bridge to function in non-promiscuous mode.
> >>>>>
> >>>>>What is the practical applications for such setup? In other words,
> >>>>>in which cases I would want to put bridge into non-promiscuous
> >>>>>mode and specify some uplink ports?
> >>>>>
> >>>>
> >>>>On of the applications would be when bridge is an edge device servicing
> >>>>a VM deployment.  Each of the VMs knows the mac address that the guest
> >>>>has and may program that mac onto the uplinks.
> >>>
> >>>Why wouldn't that environment just use macvlan?
> >>>Is it because changing libvirt is harder than changing the kernel?
> >>>
> >>
> >>No, because macvlan has a drawback that it doesn't easily let guests
> >>talk to the host.  Bridge is still most commonly used for just that reason.
> >>
> >>-vlad
> >
> >Maybe fixing that with a flag to macvlan would be easier?
> >
> 
> Not really.  macvlan to physical device could be made simple enough.
> However, physical to macvlan is non-trivial at all.
> 
> We get around this right now by crating a macvlan on the host and
> have macvlan to macvlan communication essentially turning it into
> bridge.  But that doesn't work in all scenarios either.
> 
> -vlad

Yea macvlan bridged mode is a strange beast.  It almost wants to be a
bridge, but does not dare, for example it punts on all the issues we
have fixed in the bridge like multicast snooping, and just floods
packets.

Another issue is that different VMs have different needs. You might want
to run VMs that simply use a single MAC, so no need for promisc mode,
then want to start another VM that does bridging so we need to enable
promisc mode dynamically. I guess we could switch from macvtap to
tap and back, but it's pretty nasty.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
