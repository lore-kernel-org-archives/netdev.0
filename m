From: dcn@sgi.com (Dean Nelson)
Subject: [PATCH 0/3] SGI Altix cross partition functionality (2nd
 revision)
Date: Wed, 23 Mar 2005 13:29:21 -0600
Message-ID: <4241C391.mailxHNA15A8V0@aqua.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-ia64@vger.kernel.org, netdev@oss.sgi.com
To: tony.luck@intel.com
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


    Terminology

The term 'partition', adopted by the SGI hardware designers and which
perculated up into the software, is used in reference to a single SSI
when multiple SSIs are running on a single Altix. An Altix running
multiple SSIs is said to be 'partitioned', whereas one that is running
only a single SSI is said to be 'unpartitioned'.

The term '[a]cross partition' refers to a functionality that spans between
two SSIs on a multi-SSI Altix. ('XP' is its abbreviation.)


    Introduction

This feature provides cross partition functionality when running multiple
partitions on a single SGI Altix.

This functionality includes such things as a pseudo-ethernet driver and
memory sharing, which are provided by functional support modules that sit
on top of a low-level communication module.

The communication module provides channels for point-to-point communication
between the partitions. There is support for eight channels between any
two partitions (currently only two channels are in use, the remainder are
available for possible future expansion). A functional support module uses
the same channel number for all of its cross partition communication across
the entire Altix.

There is a shim module that acts as an interface between the functional
support modules and the communication module. Its sole purpose is to allow
for the communication module to be rmmod'd/insmod'd without 'disturbing'
the functional support modules and the user processes utilizing them. The
shim module has also proven itself to be invaluable for debugging.

This feature is being submitted as three separate quilt patches:

    XP       - shim module
    XPC      - cross partition (low-level) communication module
    XPNET    - cross partition pseudo-ethernet driver functional support module

(When time permits a patch will be submitted to add XPMEM, which is the
functional support module that provides cross partition memory sharing.)

This patch set is dependent upon the following patches:

	[patch - 2.6.11-rc5-mm1] genalloc - general purpose allocator
	[patch - 2.6.11-rc5-mm1] mspec ia64 memory special driver
	[patch 1/2] Altix: Shub2 BTE support
	[patch 2/2] Altix: Shub2 BTE support - BTE recovery code
	[PATCH] move cnodeid_to_nasid_table out of pda
	[PATCH] move nodepda pointer out of pda
	[PATCH] Export node_online_map and node_possible_map
	[PATCH] convert some sn SAL_CALLs to ia64_sal_oemcall calls
	[PATCH] Define some additional SHub1 and Shub2 register symbols
	[PATCH] Add some needed externs currently not defined

( The netdev folks only need to review the XPNET patch. )
