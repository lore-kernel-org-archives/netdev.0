From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Wed, 28 Sep 2011 08:11:58 -0700
Message-ID: <20110928081158.7273e9b4@nehalam.linuxnetplumber.net>
References: <19fca01e-5827-4e28-b12c-2b65cca96878@tahiti.vyatta.com>
	<1316477404.14749.256.camel@deadeye>
	<20110920185918.GX21309@gospo.rdu.redhat.com>
	<20110920202305.GC16323@hmsreliant.think-freely.org>
	<1317167146.2845.48.camel@bwh-desktop>
	<20110928110055.GA15340@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	jeffrey t kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gospo@redhat.com, Alexander H Duyck <alexander.h.duyck@intel.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34668 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668Ab1I1PME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 11:12:04 -0400
In-Reply-To: <20110928110055.GA15340@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Sep 2011 07:00:55 -0400
Neil Horman <nhorman@tuxdriver.com> wrote:

> I was thinking of something along the lines of two more attributes in
> /sys/class/net/<if>/queues:
> napi_weight
> irq
> 
> The former is the napi weight of a given napi instance associated with a queue,
> while the latter is a symlink either to ../device/irq or ../device/msi_irqs/<n>/
> (or perhaps to ../devices/msi_irqs/<n>/irq if we want more consistency).   This
> lets us tune the napi weight of a queue and know what interrupt is associated
> with it.  That seems fairly sane to me.

This breaks for the case of some corner case devices like multi-port Marvell boards.
There can be a N to 1 or 1 to N relationship between NAPI and the device.
