From: Ben Gamari <bgamari@gmail.com>
Subject: Re: Unplug ethernet cable, the route persists.  Why?
Date: Thu, 25 Nov 2010 15:11:38 -0500
Message-ID: <87bp5df9j9.fsf@gmail.com>
References: <144174.46619.qm@web63401.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Mike Caoco <caoco2002@yahoo.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <144174.46619.qm@web63401.mail.re1.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Nov 2010 12:29:43 -0800 (PST), Mike Caoco <caoco2002@yahoo.com> wrote:
> So if you rely on NetworkManager or Connman or Quagga to remove the
> route, the routing daemons will recompute the route table anyway.  So
> why cannot this be done in the kernel?

This is policy. In the Linux world we generally strive to separate
policy from mechanism, leaving the former to userspace. This allows
(potentially complex) policy decisions to be made in user-space. The
reason for this is two-fold: First, every line of kernel code introduces
the potentially for a bug and error handling in the kernel is generally
more complex than it is in user-space. Secondly, allowing user-space to
handle policy allows users to do things with the kernel that kernel
developers did not envision. This flexibility is one reason why the
kernel is so suited for running on anything from your cell-phone to 4000
processor big iron.

> Even when no NetworkManager/Quagga is present, I think it is a
> legitimate reason to recompute the route when a cable is unplugged,
> which should not be a frequent event unless when under error
> conditions.

There have to be real, demonstrable benefits for moving policy into the
kernel (i.e. the recent discussions concerning per-session
cgroups). Considering how long the Linux networking subsystem has
existed, I highly doubt there is a good reason to move this sort of
routing policy into the kernel that has not already been discussed.

Cheers,

- Ben
