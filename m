From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: Steps for netdev-2.6 inclusion?
Date: Thu, 02 Dec 2004 14:11:52 -0600
Message-ID: <41AF7708.3030804@linux.intel.com>
References: <41AE7143.80505@linux.intel.com> <41AEB3B8.2000406@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41AEB3B8.2000406@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> It's fairly easy, just email me and netdev the patch for inclusion, 
> and it'll get reviewed.

Should I break the patch into the three components (ipw2100, ipw2200, 
and ieee80211) ? or just one huge patch?  Not sure what you and others 
would prefer.

> Once review issues are addressed, I'll merge it immediately, which 
> causes it to be automatically propagated to Andrew Morton's -mm tree 
> for testing.
>
> Once consensus agrees that we can push this + HostAP upstream, that's 
> an easy 10-minute task.
>
> One potential showstopper is firmware crapola:  I'm concerned about a 
> situation where we have drivers in the kernel, but the firmware must 
> be downloaded from SourceForge or somesuch.

The firmware doesn't have to be downloaded from Sourceforge, but it does 
need to exist on the system, just as iwconfig needs to exist if you want 
to be able to configure your wireless card.  The user can get the 
firmware from Sourceforge, or have it installed by their distribution or 
package management system, have it on their Knoppix CD, etc. 

Loading the driver without the firmware (or hotplug being enabled) won't 
take down the machine -- it will just print a kernel log message saying 
the firmware can't be found.

For some common questions and answers on the redistribution of the 
license, see http://intel.com/support/wireless/wlan/sb/cs-016675.htm

Regarding the topic of loading firmware from disk... the firmware_class 
subsystem was designed for this purpose.

 From linux/Documentation/firmware_class/README:

------------------
 Why:
 ---

 Today, the most extended way to use firmware in the Linux kernel is linking
 it statically in a header file. Which has political and technical issues:

  1) Some firmware is not legal to redistribute.
  2) The firmware occupies memory permanently, even though it often is just
     used once.
  3) Some people, like the Debian crowd, don't consider some firmware free
     enough and remove entire drivers (e.g.: keyspan).
-------------------

Point one is partially applicable -- redistribution of the ipw firmware 
*is* legal, but due to the terms of the GPL, inclusion in the kernel is 
not possible (the firmware can't be licensed GPL, and so static 
inclusion in the driver as a header binary is impossible.)  So, the 
firmware must be loaded onto the NIC from some other storage medium.

The second point from the firmware_class's README is also valid 
(although the current state of suspend/resume necessitates a 
pre-allocated memory buffer in the driver.  Once that issue is remedied, 
the host will be able to free up a reasonable amount of memory that is 
otherwise unnecessary.)

> IOW, the kernel driver as-is is useless without a differently-licensed 
> firmware.

Wireless (and many other kernel components) are arguably useless without 
user space utilities that must be downloaded, built, and installed.  So 
the issue of having to download something, or have some other 
pre-requisite met before the driver is useful/functional is not unique 
to this driver.

James
