From: dcn@sgi.com (Dean Nelson)
Subject: [PATCH 0/4] SGI Altix cross partition functionality (1st
 revision)
Date: Tue, 24 Aug 2004 13:00:30 -0500
Sender: linux-ia64-owner@vger.kernel.org
Message-ID: <412B823E.mailxAMX1HROPJ@aqua.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-ia64-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-ia64@vger.kernel.org
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

This feature is being submitted as four separate quilt patches:

    exports  - symbols that need to be exported for XP[C|NET]
    XP       - shim module
    XPC      - cross partition (low-level) communication module
    XPNET    - cross partition pseudo-ethernet driver functional support module

The XPC patch is dependent on the SGI fetchop driver patch to be applied
first. The SGI fetchop driver patch is being pushed out to the community
separately by Robin Holt.

The XPC patch is also dependent on bte_copy(). This function activates
the SGI Altix's Block Transfer Engine (BTE).

[ The netdev folks only need to review the XPNET patch. ]
