From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: 3945 driver using d80211
Date: Tue, 8 Aug 2006 17:06:31 -0700
Message-ID: <20060809000631.GH25393@instant802.com>
References: <44D901C9.6090304@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-17.dex002.intermedia.net ([64.78.21.83]:58487 "EHLO
	dhost002-17.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751079AbWHIPyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 11:54:55 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <44D901C9.6090304@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 02:27:37PM -0700, Mohamed Abbas wrote:

> 1- I needed to use sta_info_get function to do rate scaling for 3945,=
=20
> although this function is exported but it was missing from d80211.h, =
for=20
> work around I had to copy more header files to my driver's directory,=
 It=20
> this plan to add this function to d80211.h ?

sta_info_get() (and well, any access to struct sta_info) was not
designed to be available for the rate control modules. Could you please
provide some more details on what kind of information you would need
from there?

> 2- Scanning; in 3945 driver, we can not tune to other channels while =
we=20
> are connected, this will cause a firmware error. The firmware provide=
s a=20
> scanning command we call so the firmware will take care of switching =
of=20
> the available channels and gather beacons and probe responses. The=20
> current d80211 the stack will call config callback to switch to=20
> different channel and send the probe requests. One of our engineers d=
id=20
> come up with a patch to add one more callback function if provided th=
e=20
> d80211 will call this function to allow the registered driver to perf=
orm=20
> the scanning functionalities. For work around I currently check insid=
e=20
> config callback if the scanning flag set I will issues the scan comma=
nd=20
> then ignore the next config callback.

If the hardware/firmware has such limitation, providing an alternative
mechanism for this is indeed needed. However, I though 3945 did not hav=
e
much firmware on it and I was not expecting this kind of requirement
from it (though, I have to admit that I'm not at all familiar with the
details of its design). Anyway, there are other wireless cards that wil=
l
need similar mechanism, so this is needed to support more "full mac"
type designs.

> 3- I can not access beacon's info from current associated AP.=20
> information I need to callback into the firmware like timestamp and a=
id,=20
> work around I would parse incoming management frame and filter beacon=
=20
> from associated AP to get this info. This is a duplicate code that=20
> d80211 stack doing, maybe there is away to get these info that I don=E2=
=80=99t=20
> know of. Also it will be nice to have some callback function on=20
> association, disassociation.

What kind of information/events do you need in the low-level hardware
driver? It sounds reasonable to add this kind of event callbacks.

> 4- I am been using the driver for sometime right now and it seems to =
be=20
> stable and liable although I am using SMP system. I hearted of some S=
MP=20
> issues in d80211 and I have the machine and time to help in this. Do =
you=20
> have any test script the cause this SMP problems? Or steps to reprodu=
ce it.

I have heard of open claims on there being SMP issues, but I don't thin=
k
I've ever seen any details on this. I've also added a dual core laptop
to my testbed, so it will be interesting to see whether I can trigger
any of the issues easily.

--=20
Jouni Malinen                                            PGP id EFC895F=
A
