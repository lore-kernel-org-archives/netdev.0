From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [PATCH SET][bonding 2.4] cleanup
Date: Thu, 4 Dec 2003 17:13:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312041713.52021.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-Disposition: inline
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Here is another go with the bonding cleanup. This set is similar to 
the previous set I sent on 10/12, but built against 2.4.23 and 
includes the silent failure fix reported by Per Hedeland.
The set is broken down to many patches for better tracking. It has 
already undergone a thorough set of testing by our QA group, and is 
the basis for all future developments we plan for bonding.

Jeff,
Please apply this set and forward it to Marcelo for inclusion in 
2.4.24-pre1 since I was told by Jay it would be OK to apply this set 
once 2.4.23 is released.

Set can be downloaded from:
http://osdn.dl.sourceforge.net/sourceforge/bonding/bonding_cleanup_3-2.4.23.tar.bz2

It will update the following files:
	Documentation/networking/bonding.txt
	Documentation/networking/ifenslave.c
	drivers/net/bonding/bond_3ad.c
	drivers/net/bonding/bond_alb.c
	drivers/net/bonding/bond_alb.h
	drivers/net/bonding/bonding.h
	drivers/net/bonding/bond_main.c
	include/linux/if_bonding.h

Description:
patch 1 - ifenslave lite - No more IP settings to slaves, unified
          printing format, code re-org and broken to more
          functions.
patch 2 - convert all debug prints to use the dprintk macro and 
          consolidate format of all prints (e.g. "bonding: Error: 
          ...").
patch 3 - death of typedef. eliminate bonding_t/slave_t types and
          consolidate casting.
patch 4 - remove dead code and redundant checks.
patch 5 - consolidate timers initialization, error checking and
          re-queuing.
patch 6 - convert too long if-else to a switch-case. Fix all
          locations that handles bond->primary.
patch 7 - eliminate the multicast_mode module param. settings are
          now done only according to mode.
patch 8 - slave list iteration - bond is no longer part of the
          list, added cyclic list iteration macros.
patch 9 - consolidate function declarations:
          o all functions begin with bond_
          o return value, function name and all params are on the
            same line.
          o change some function names to be more descriptive.
patch 10 - consolidate names of function params and variables (e.g.
           bond_dev instead of dev/master/master_dev).
patch 11 - change names/types for some of the members in struct
           bonding. change position of members.
patch 12 - consolidate return values of functions.
patch 13 - put curly braces around all if, else, for, while, switch
           statements. change conditions to short format.
           e.g. (ptr == NULL) ==> (!ptr)
patch 14 - consolidate error handling in all xmit functions.
patch 15 - chomp all trailing white space.
patch 16 - remove duplicate empty lines. add empty lines where
           needed to improve readability.
patch 17 - fix indentations.
patch 18 - code re-organization in bond_main.c according to context
           (e.g. module initialization, bond initialization, device
           entry points, monitoring, etc).

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
