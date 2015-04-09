From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] ipvlan: fix up broadcast MAC filtering for ARP and DHCP
Date: Thu, 09 Apr 2015 17:18:55 -0500
Message-ID: <1428617935.352.0.camel@redhat.com>
References: <1427409698.18540.11.camel@redhat.com>
	 <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
	 <1427749308.1913.28.camel@redhat.com>
	 <CAF2d9jipTV4f4NOgGRY-kGOyRBe5HAH6T-mj4G9FYnc7oyc+NA@mail.gmail.com>
	 <1427771158.1913.35.camel@redhat.com> <1427775770.30696.3.camel@redhat.com>
	 <CAF2d9jikrJU0k3sS=awZQN+SD46qnN4r0bubjXZiY7K9vQieEQ@mail.gmail.com>
	 <1427921700.6874.8.camel@redhat.com>
	 <CAF2d9jgqJBfWVnX1mye5xMfYznA_NFte3dEEKG5CyogXTM73Rw@mail.gmail.com>
	 <1427985636.5282.9.camel@redhat.com>
	 <CAF2d9jjBtSptfmFY2BDF7ULNxAz=WtUVpNz0iExyd-h+v+4GSQ@mail.gmail.com>
	 <1428340638.16890.15.camel@redhat.com>
	 <CAF2d9jgx6R5w_PoVzkstVgr0tATxTQv9S81QC9_YiX32vpRQVA@mail.gmail.com>
	 <1428435900.6449.25.camel@redhat.com> <1428594679.15316.0.camel@redhat.com>
	 <CAF2d9jgZ+32LT5FxcqH97n1rbEChEgK7a4RtCEiUaUWOEyTmhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>, jbenc@redhat.com
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505AbbDIWSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 18:18:15 -0400
In-Reply-To: <CAF2d9jgZ+32LT5FxcqH97n1rbEChEgK7a4RtCEiUaUWOEyTmhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 09:33 -0700, Mahesh Bandewar wrote:
> >> Yes, it's still snooping for all packets, but it's a lot fewer compares
> >> than looking for DHCP specifically.
> >
> > Any thoughts on this Mahesh?  Is this non-DHCP approach more to your
> > liking?  If so I'll generate an actual patch and do some testing.
> >
> Sorry about the late reply but some how I missed that.
> 
> Yes, this looks better, but I'm thinking of solving this issue with a
> different approach which does not involve snooping. Or if it does, it
> wont be in a fast path! It is sort of falling back to your original
> patch which eliminates setting / resetting the broadcast bit but after
> deferring the broadcast / multicast processing to a work-queue. This
> will keep the fast path clean and we can do all sort of jugglery in
> work-queue (if needed) without affecting the performance of the device
> (fast path) whether it's IPv6 or IPv4 traffic.
> 
> Also Eric pointed out how multicast is broken in IPvlan, that needs a
> fix too. I have cooked something, but needs some testing, I'll push
> out those patches as soon as I'm happy with it's testing.

I'm quite happy to test those patches when you post them too.

Dan
