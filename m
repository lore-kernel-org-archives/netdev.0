From: rdbrown@mira.net
Subject: Suggested patch to include attribution for faster CRC algorithm
Date: Tue, 21 Oct 2003 00:32:08 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020143208.GA576@urtur>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rbrown64@csc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch to include attribution for the faster CRC algorithm used in
lib/crc32.c . As I read it Richard Black implied a BSD style license as
long as the Copyright was included. The source was based on his code.
I think http://research.microsoft.com/users/rjblack/ may be the right
person if he should be contacted. I don't like the long line for the URL
- I guess you could lose the section part if preferred.
Source modified from 2.6.0-test4, untested as a comment change.

--- lib/crc32.c	Sat Aug 23 09:50:53 2003
+++ lib/crc32.c	Sun Oct 19 23:40:32 2003
@@ -1,6 +1,9 @@
 /* 
  * Oct 15, 2000 Matt Domsch <Matt_Domsch@dell.com>
  * Nicer crc32 functions/docs submitted by linux@horizon.com.  Thanks!
+ * CRC_?E_BITS == 8 forms based on Algorithm 4 from
+ * http://www.cl.cam.ac.uk/Research/SRG/bluebook/21/crc/node6.html#SECTION00064000000000000000
+ * which is Copyright 1993 Richard Black, All rights reserved.
  *
  * Oct 12, 2000 Matt Domsch <Matt_Domsch@dell.com>
  * Same crc32 function was used in 5 other places in the kernel.


The statement from the web page (tex source) was
\subsection{Algorithm four}

This code is copyright~\copyright~1993 Richard Black. All rights are
reserved. You may use this code only if it includes a statement to
that effect.


Following are excerpts from the mailing lists showing the history of
the code.

Following includes first use of Algorithm 4
http://www.ussg.iu.edu/hypermail/linux/kernel/0211.2/1895.html
Re: [PATCH 2.5] crc32 static initialization
From: Brian Murphy (brian@murphy.dk)
Date: Fri Nov 22 2002 - 15:25:22 EST

Joakim Tjernlund wrote:

>Hi Brian
>
>Would you please also add the CRC32 patch I sent you earlier?
>It is much faster.
>
>
>
Can you test the attached patch - especially on a big endian system. It
should
do the required thing, i.e. what you want and what I want :-)
simultaneously.

/Brian 


Earlier Algorithm 4
http://www.ussg.iu.edu/hypermail/linux/kernel/0211.2/1525.html
Early crc32 initialization
From: Joakim Tjernlund (joakim.tjernlund@lumentis.se)
Date: Thu Nov 21 2002 - 05:16:48 EST
Brian Murphy posted this on 8-Oct with no response. Quoting:

Here is a patch to the crc32 library routine to allow explicit
initialization of the tables used by the routines.

I need this to be able to use the crc routines in the early
start up code for my platform which saves crc protected
information (clock speed, machine type) in an eeprom.

The option CONFIG_CRC32_EXPLICIT is defined for the platforms
which need it in the config.in file.

I have removed dynamic allocation of memory because the
memory subsystem is also not initialised at the stage where I
need the crc functions.

/Brian

Hi Matt and Brian

I have doen an optimiztion that improves scan time in JFFS2 with more that 25% for
my PPC custom board. This patch needs to use __cpu_to_be32()/__cpu_to_le32() on the
tables. That may cause problems if a static table is to be used. See below:

 Jocke 


Explicit reference to algorithm 4
http://lists.infradead.org/pipermail/linux-mtd/2002-November/006422.html
crc32() optimization
Joakim Tjernlund Joakim.Tjernlund at lumentis.se
Sun Nov 10 21:04:11 GMT 2002

    * Previous message: crc32() optimization
    * Next message: Building mkfs.jffs2
    * Messages sorted by: [ date ] [ thread ] [ subject ] [ author ]

hmm , maybe. I tried 16, 8 & 4 also, but 6 was a little faster for me.
What would be great if someone that understands CRC better than me could
take a look at Algorithm 4 at http://www.cl.cam.ac.uk/Research/SRG/bluebook/21/crc/node6.html#SECTION00060000000000000000
and apply that on linux CRC32 code.  I tried but failed to get it correct.

        Jocke
