From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Sun, 17 Jan 2010 09:22:21 -0800
Message-ID: <20100117092221.2fca789c@nehalam>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
	<20100114145633.4c2d4ac6@nehalam>
	<1263607893.17815.114.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41780 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174Ab0AQRWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2010 12:22:48 -0500
In-Reply-To: <1263607893.17815.114.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 16 Jan 2010 02:11:33 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Thu, 2010-01-14 at 14:56 -0800, Stephen Hemminger wrote:
> > On Thu, 14 Jan 2010 13:56:23 -0800 (PST)
> > Tom Herbert <therbert@google.com> wrote:
> [...]
> > > The CPU masks is set on a per device basis in the sysfs variable
> > > /sys/class/net/<device>/rps_cpus.  This is a set of canonical bit maps for
> > > each NAPI nstance of the device.  For example:
> > > 
> > > echo "0b 0b0 0b00 0b000" > /sys/class/net/eth0/rps_cpus
> > 
> > Why not make a kobject out of cpus which would add subdirectory.
> > This would keep interface consistent with the one value per file
> > semantic of sysfs.
> 
> Do you mean a kobject per NAPI context, each initially with a rps_cpus
> attribute holding a CPU mask, or a kobject per CPU, each with an
> attribute specifying which NAPI contexts it does work for?  (Personally
> I'd favour the first.)

Yes, make NAPI real kobjects, linked to device.

BUT
make sure this also handles case of N to 1 mapping as well
as 1 to N case.
