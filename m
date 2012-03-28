From: Jim Cromie <jim.cromie@gmail.com>
Subject: maranello for linux-current [b43 driver]
Date: Wed, 28 Mar 2012 16:24:17 -0600
Message-ID: <CAJfuBxz9kVAkkSjFk2PAYLxOsgmrCx-HV0OM7EwV9J5mSzB8dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Bo Han <bohan@cs.umd.edu>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:57425 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758808Ab2C1WYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 18:24:48 -0400
Received: by gghe5 with SMTP id e5so1148709ggh.19
        for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 15:24:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

you may have heard of maranello, a project to add
partial packet recovery to 80211, by adding block checksums
on transmit, validating them or re-requesting retransmit
of corrupted blocks.

http://www.cs.umd.edu/projects/maranello/

the code at the page is for 2.6.29-rc2

Ive taken it, did some refactoring to ease merging,
and merged in each linux release, up to 3.3

The refactoring is:

- move code from include/net/mac80211.h utils.c to
drivers/net/wireless/maranello.*
this makes it somewhat common, but more isolated overall,
and reduces merge conflicts due to continued evolution of those files.
I imagine new code would eventually go back to the original files, but
not for a while.

- move most of new code in each *.c file to *_mnlo.c
fn decls added to corresponding *.h
again, this code probably would be moved back to original *.c, but not yet.


After all the merges, I compiled, and found some errors.
I had problems building plain 2.6.29-rc2, and several later releases,
so punted on compiling every step.

The compile errors are fixed on top of the merges, but ideally should be
rearranged to fix each release.  This requires more git-fu than I possess,
and IIUC, netdev ML is more interested in patches to linux-current.

Repeating:  this is only compile tested, I dont have a b43 based wifi card
in my desk/lap-tops.

I do have a WRT54G router, currently running openWRT 10.03
which does have a b43 wifi chip.  I intend to try putting this code
there eventually,
but that may take a while yet, and cannot test maranello itself anyway.

Having split maranello code into new files, I have some misgivings about
that approach - it simplified merges, but at the cost of not seeing
the underlying conflicts.  The compiler told me about some, surely others lurk.

So I guess Im seeking advice:

- what did I break
- what happens when the driver is tested
- whether to repeat this merge-effort w/o the split

- why did earlier releases fail to build
  [jimc@groucho linux-2.6]$ git checkout v2.6.29
  [jimc@groucho build-dell-2]$ make xconfig
  Makefile:23: *** mixed implicit and normal rules.  Stop.
  I also see breakage on unrelated stuff (that builds fine on mainline)
  [jimc@groucho build-dell-2]$ make
  AS      arch/x86/xen/xen-asm_64.o
  /home/jimc/projects/lx/linux-2.6/arch/x86/xen/xen-asm_64.S:
Assembler messages:
  /home/jimc/projects/lx/linux-2.6/arch/x86/xen/xen-asm_64.S:48:
Error: unsupported for `mov'
  ...
the tree is here:
https://github.com/jimc/linux-2.6/tree/maranello/released-split

Im happy to open it up for collaboration if theres interest,
I'll have to figure out how to do that though..
Of course you can clone and fork it.

Its probably premature to concentrate on rework for inclusion,
I think itd be better to get it working on mainline 1st,
but the long view might inform the short-term steps.

thanks
Jim Cromie
