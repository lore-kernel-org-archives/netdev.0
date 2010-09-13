From: Caglar Akyuz <caglarakyuz@gmail.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Mon, 13 Sep 2010 20:51:46 +0300
Message-ID: <201009132051.46042.caglarakyuz@gmail.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <201009111154.42171.caglarakyuz@gmail.com> <4C8E308B.7020003@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Williamson <michael.williamson@criticallink.com>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: cyril@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4C8E308B.7020003@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 September 2010 05:09:15 pm Cyril Chemparathy wrote:
> Hi Caglar,
> 
> [...]
> 
> > Unfortunately emac driver is not stable after this series. I face
> > lock-ups time to time, followed by attached kernel trace.
> 
> Could you elaborate on your test scenario so that I can try and
> reproduce the problem at my end?  Also, did you have the contents of my
> commit stack in this particular kernel build?
> 

Ooops! I didn't noticed your commits till you noted, I was working with 
DaVinci head. Applying patches in your tree solves all my problems and all my 
use cases are working now. However, I just barely tested them.

To make myself forgiven here are my 'netperf' numbers before and after your 
patches applied:

  TCP_STREAM  	:	54.64 Mbit vs 52.84 Mbit        
  UDP_STREAM   	:       96.27 Mbit vs 96.22 Mbit

Regards,
Caglar

> Assuming that the DMA got stuck at some point leading up to the transmit
> timeout, any ideas as to why a host error was not thrown?  To help
> debug, I'll post out a set of patches that dump out the MAC (and DMA)
> registers on timeout.  That should give us some visibility into the
>  problem.
> 
> > [ 1651.440000] nfs: server 192.168.2.34 not responding, still trying
> > [ 1859.010000] ------------[ cut here ]------------
> > [ 1859.010000] WARNING: at net/sched/sch_generic.c:258
> > dev_watchdog+0x184/0x294()
> > [ 1859.020000] NETDEV WATCHDOG: eth0 (davinci_emac): transmit queue 0
> > timed out
> 
> [...]
> 
> Regards
> Cyril.
> 
