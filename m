From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] smsc911x: add fifo byteswap support
Date: Thu, 23 Apr 2009 11:09:25 +0900
Message-ID: <20090423020925.GA8818@linux-sh.org>
References: <20090422145553.25073.99410.sendpatchset@rx1.opensource.se> <OFC89C8D8B.9962FD9A-ON802575A0.005335A8-802575A0.00545CBF@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Magnus Damm <magnus.damm@gmail.com>, davem@davemloft.net,
	iwamatsu@nigauri.org, netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 124x34x33x190.ap124.ftth.ucom.ne.jp ([124.34.33.190]:35449 "EHLO
	master.linux-sh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbZDWCOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 22:14:36 -0400
Content-Disposition: inline
In-Reply-To: <OFC89C8D8B.9962FD9A-ON802575A0.005335A8-802575A0.00545CBF@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 04:21:32PM +0100, Steve.Glendinning@smsc.com wrote:
> Magnus Damm <magnus.damm@gmail.com> wrote on 22/04/2009 15:55:53:
> 
> > From: Magnus Damm <damm@igel.co.jp>
> > 
> > This patch adds fifo byteswap support to the smsc911x driver.
> > 
> > The smsc911x hardware supports both big and little and endian
> > hardware configurations, and the linux smsc911x driver currently
> > detects word order.
> > 
> > For correct operation on big endian platforms lacking swapped
> > byte lanes the following patch is needed. Only fifo data is
> > swapped, register data does not require any swapping. 
> > 
> > Signed-off-by: Magnus Damm <damm@igel.co.jp>
> 
> I guess this is to work around a problem with hardware that's
> already in production?
> 
Good guess ;-)

> The best solution would be to swap the byte lanes in hardware,
> as the device's endian swapping features only affect registers
> (not the FIFOs).  The very latest devices in this family
> (such as the LAN9221) can swap both independently, but this
> driver has to also support older parts.
> 
> Performance will be suboptimal with this software byteswapping,
> so I think we should also add a comment to stress that this is
> a "last resort" workaround for broken hardware.
> 
> Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

Performance is not much of a consideration here, it's basically between
this and no ethernet at all. On the plus side, at least not many boards
will need this, I believe it's only 2 generations of microcontroller
evaluation boards that suffer from this particular bit of idiocy on our
side.
