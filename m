From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [PATCH SET][bonding 2.4] cleanup - take 3
Date: Sun, 12 Oct 2003 17:48:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310121748.44673.shmulik.hen@intel.com>
References: <200309251549.59177.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
In-Reply-To: <200309251549.59177.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Here is another go with the bonding cleanup. This set is similar to 
the previous set I sent on 9/25, but it does not touch compatibility 
stuff and there are several bug fixes. This set is very comprehensive 
and touches almost all the code. The set is broken down to many 
patches for better tracking. It was already tested by me for 
functionality and is in the process of a more thorough set of testing 
by our QA group for any corner case bugs.

This set applies on 2.4.23-pre7, after the compatibility bug fix patch 
I sent earlier today is accepted.

It can be downloaded from:
http://osdn.dl.sourceforge.net/sourceforge/bonding/bonding_cleanup_2-2.4.23-pre7.tar.bz2

This will update the following files:
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
