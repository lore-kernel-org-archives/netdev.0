From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ixgbe: take online CPU number as MQ max limit when alloc_etherdev_mq()
Date: Fri, 13 May 2016 09:46:37 -0700
Message-ID: <CAKgT0UeiEW21E7A9fnt_BUCppopns-E2w1WbwF-8A6sCZkJ8rQ@mail.gmail.com>
References: <1463118995-31763-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ethan Zhao <ethan.kernel@gmail.com>
To: Ethan Zhao <ethan.zhao@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33590 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbcEMQqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 12:46:38 -0400
In-Reply-To: <1463118995-31763-1-git-send-email-ethan.zhao@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2016 at 10:56 PM, Ethan Zhao <ethan.zhao@oracle.com> wrote:
> Allocating 64 Tx/Rx as default doesn't benefit perfomrnace when less
> CPUs were assigned. especially when DCB is enabled, so we should take
> num_online_cpus() as top limit, and aslo to make sure every TC has
> at least one queue, take the MAX_TRAFFIC_CLASS as bottom limit of queues
> number.
>
> Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>

What is the harm in allowing the user to specify up to 64 queues if
they want to?  Also what is your opinion based on?  In the case of RSS
traffic the upper limit is only 16 on older NICs, but last I knew the
latest X550 can support more queues for RSS.  Have you only been
testing on older NICs or did you test on the latest hardware as well?

If you want to control the number of queues allocated in a given
configuration you should look at the code over in the ixgbe_lib.c, not
ixgbe_main.c.  All you are doing with this patch is denying the user
choice with this change as they then are not allowed to set more
queues.  Even if they find your decision was wrong for their
configuration.

- Alex
