From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [bonding][3/3] Synchronizing 2.4-2.6
Date: Wed, 27 Aug 2003 20:08:20 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308272008.20139.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>From another mail from Jay Vosburgh:
>
>         This sort of wholesale cleanup is something I've been
> itching to do for a long time, but never had the time for.  I'm all
> in favor of it in general; I'll have to see what I think about all
> of the specific changes after I look through the rest of the
> patches.  In general, the bonding source has gotten fairly messy
> and hard to follow, so I think cleanup is needed.
>

This is set 3 - the wholesale cleanup. It's a re-send, only it was 
divided into smaller change sets to make them more readable and 
smaller in size. A few new things were added as well.

Applies on 2.4.22. Assumes patch set 2 was already applied.

patch set can be downloaded from:
http://osdn.dl.sourceforge.net/sourceforge/bonding/patch_set_3_cleanup.tar.bz2

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
patch 1 - ifenslave.c lite - no more IP settings + code re-org.
patch 2 - convert all debug prints to use the dprintk macro and 
	  consolidate format of all prints (e.g. "bonding: Error: ...").
patch 3 - death of typedef. eliminate bonding_t/slave_t and 
	  consolidate casting.
patch 4 - remove dead code and redundant checks. add a few new checks 
	  where needed.
patch 5 - consolidate timers initialization, error checking and 
	  re-queuing.
patch 6 - convert too long if-else to a switch-case. Fix all locations 
	  that handles bond->primary.
patch 7 - eliminate the multicast_more module param and use the 
	  USES_PRIMARY macro instead.
patch 8 - consolidate slave list iterations.
patch 9 - consolidate function declarations:
	o all functions begin with bond_
	o return value, function name and all params are on the same line.
patch 10 - consolidate names of function params and variables (e.g. 
	   bond_dev instead of dev|master|master_dev).
patch 11 - change names for a few of the members of struct bonding.
patch 12 - consolidate return values of functions.
patch 13 - put curly braces around all if, else, for, while, switch 
	   statements. consolidate if conditions
	   e.g. (ptr == NULL) --> (!ptr)
patch 14 - chomp all trailing white space.
patch 15 - remove duplicate empty lines. add empty lines to improve 
	   readability.
patch 16 - fix indentations.
patch 17 - code re-organization in bond_main.c according to context
	   (e.g. module initialization, bond initialization, device entry 
	    points, monitoring, etc.).
	   it just looks unreadable, but in fact its very simple :)

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
