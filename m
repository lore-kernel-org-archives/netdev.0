From: Adrian Bunk <bunk@fs.tum.de>
Subject: Re: SCTP config 2.5.70(-bk)
Date: Tue, 3 Jun 2003 15:03:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603130308.GC27168@fs.tum.de>
References: <5.1.0.14.2.20030602094232.00aeda18@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>,
   lksctp-developers@lists.sourceforge.net
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20030602094232.00aeda18@pop.t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 02, 2003 at 09:53:04AM +0200, Margit Schubert-While wrote:

> CONFIG_IPV6_SCTP__   is always being set to "y" even though
> not selected (CONFIG_IPV6 not set)

First, this doesn't do any harm since CONFIG_IPV6_SCTP__ alone doensn't 
result in anything getting compiled.

But besides, it seems a bit broken.

>From net/sctp/Kconfig:

<--  snip  -->

...

config IPV6_SCTP__
        tristate
        default y if IPV6=n
        default IPV6 if IPV6

config IP_SCTP
        tristate "The SCTP Protocol (EXPERIMENTAL)"
        depends on IPV6_SCTP__
...

<--  snip  -->


Semantically equivalent is the following for IPV6_SCTP__:

config IPV6_SCTP__
        tristate
        default y if IPV6=n || IPV6=y
	default m if IPV6=m


If it was intended to disallow a static IP_SCTP with a modular IPV6 it 
doesn't work: It's perfectly allowed to set IPV6=n and IP_SCTP=y and 
later compile and install a modular IPV6 for the same kernel.


Could someone from the SCTP developers comment on the intentions behind 
IPV6_SCTP__ ?


> Margit

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
