From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [PATCH net-next] myri10ge: allow per-board firmware overriding
Date: Sun, 19 Apr 2009 01:25:38 -0400
Message-ID: <f73f7ab80904182225n4c48f891g796324bea71f535a@mail.gmail.com>
References: <49E7239B.4000309@myri.com>
	 <20090417095038.49b745bf@dhcp-lab-109.englab.brq.redhat.com>
	 <49EA1DAC.1000602@myri.com>
	 <1240102617.5342.6.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:14798 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbZDSFZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2009 01:25:39 -0400
In-Reply-To: <1240102617.5342.6.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 18, 2009 at 8:56 PM, David Dillow <dave@thedillows.org> wrote:
> On Sat, 2009-04-18 at 20:36 +0200, Brice Goglin wrote:
>> Stanislaw Gruszka wrote:
>>
>> > This would help in situation like this - admin will not have to thinking
>> > about boards initialization ordering. Besides some other drivers (like MTD
>> > cmd partitions) use own parsing for similar things, I think would be
>> > nice to unify things. What You think?
>> >
>>
>> We actually thought about supporting "eth2:fwname1,eth0:fwname2". But it
>> might be hard to implement in this case due to udev possible renaming
>> interfaces and this firmware names being needed *before* the renaming.
>> So yes, an automatic way to handle such parameter strings might be good,
>> but maybe not in this exact case.
>
> It seems like this could be done in user space, using the PCI bus ID as
> a key to select the firmware. The uevent identifies which device is
> requesting the firmware, so some modification to /lib/udev/firmware.sh
> should do it.
>
> Not that I really want to encourage relying on the bus ID being part of
> the path to the firmware files, as if no one uses it, it makes it easier
> to cache firmware files for multiple devices, but that's work for
> another day and the ABI is already set anyway...

The company I work for (eXMeritus) actually had an internal patch to
do something like this on a much older version of the driver (and I
believe we may have been the original motivation for this new patch).
We were fiddling with the firmware path to first look up (for example)
"myri10ge_eth_z8e_${PCI_BUS_ADDR}.dat", followed by
"myri10ge_eth_z8e.dat" if that failed.  Unfortunately on the RHEL5
kernel we were using at the time, the firmware filenames seemed to get
truncated at 29 characters or something, because we got requests for
"/lib/firmware/myri10ge_eth_z8e_0000:08:0a.0" and
"/lib/firmware/myri10ge_ethp_z8e_0000:08:0a."

As David notes, RHEL5 uses its own binary helper that would need some
extra help (which was why we wrote our original patch), but we would
be perfectly fine with doing normal udev rule fiddling on any other
Linux distro.

Cheers,
Kyle Moffett
