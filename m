From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH net-next] myri10ge: allow per-board firmware overriding
Date: Mon, 20 Apr 2009 11:40:41 +0200
Message-ID: <20090420114041.37c7fa7b@dhcp-lab-109.englab.brq.redhat.com>
References: <49E7239B.4000309@myri.com>
	<20090417095038.49b745bf@dhcp-lab-109.englab.brq.redhat.com>
	<49EA1DAC.1000602@myri.com>
	<1240102617.5342.6.camel@obelisk.thedillows.org>
	<1240108599.5342.11.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58607 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753292AbZDTJrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 05:47:04 -0400
In-Reply-To: <1240108599.5342.11.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 18 Apr 2009 22:36:39 -0400
David Dillow <dave@thedillows.org> wrote:

> > > We actually thought about supporting "eth2:fwname1,eth0:fwname2". But it
> > > might be hard to implement in this case due to udev possible renaming
> > > interfaces and this firmware names being needed *before* the renaming.

I was thinking about ID as serial number or MAC address - rather than device
name - something that driver specific and uniquely identify device. 

> > It seems like this could be done in user space, using the PCI bus ID as
> > a key to select the firmware. The uevent identifies which device is
> > requesting the firmware, so some modification to /lib/udev/firmware.sh
> > should do it.
> 
> On further inspection, that should work on Fedora 10, and it looks like
> other distros that use the upstream udev rules. RHEL5 uses a binary
> helper, so changing 05-early-rules.sh to use a script similar to udev's
> firmware.sh would work. YMMV elsewhere, those are the ones I had handy
> and happened to be working on some udev rules.

Module parameters I'm thinking about are not intended only for firmware names,
it could replace any device parameter which is needed during initialization.
Currently devices use module_param_array and code like this:

	dev->my_param = default;
	if (board_no < MAX_BOARDS)
		dev->my_param = my_param[board_no++];

This solution have drawbacks:

- it limits number of device instances which can get parameter
- assume initialization ordering is constant.
- assume initialization is not done in parallel 

Providing module_param_id would address this issues, but I have some concerns
before doing it:

- device have to access ID (like serial no) before initialization (at least
  before driver will need parameter)
- why nobody already done it - perhaps such thing would be totally useless


Cheers
Stanislaw
