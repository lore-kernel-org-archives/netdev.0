From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] natsemi update 3/4 External PHY operation
Date: Tue, 08 Jun 2004 07:30:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C54EE9.3090901@colorfullife.com>
References: <200406041455290031.0BC56C76@136.179.85.112> <40C33D38.1060102@colorfullife.com> <200406071608450571.1B7B9754@136.179.85.112>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gary N Spiess <Gary.Spiess@Intermec.com>
In-Reply-To: <200406071608450571.1B7B9754@136.179.85.112>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Gary N Spiess wrote:

>The existing driver code was already written to reference the "current PHY" with address 1.  To select a different address to represent the current PHY would have required me to touch more lines of source.
>
>  
>
Then touch more lines of source - the patch as it is is unreadable.

>- The partial reset fix (again, to the best of my knowledge) is only needed when the internal PHY being used has reset, but the MAC has not.  The dspcfg != np->dspcfg test identifies an internal PHY that has been reset, and triggers the driver to do a a complete MAC/PHY reset.  When using an external PHY, the test continually causes unneeded resets.  The change to set np->dspcfg to 0 prevents it.  This was the minimal change to get the desired results.
>
Again, miminal change doesn't matter. Add a

+ if (dev->if_port != PORT_TP) return;

into {do,undo}_cable_magic() and netdev_timer(). Perhaps with a comment 
that the following block is specific to the internal PHY.

--
    Manfred
