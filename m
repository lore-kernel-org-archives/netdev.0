From: Martin Devera <devik@cdi.cz>
Subject: Re: ANK's PSCHED_TDIFF_SAFE change unmasked old bug (~0UL !=
 0xFFFFFFFF)
Date: Thu, 16 May 2002 17:11:39 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0205161710030.12674-100000@luxik.cdi.cz>
References: <Pine.GSO.4.05.10205161634030.10809-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
In-Reply-To: <Pine.GSO.4.05.10205161634030.10809-100000@mausmaki.cosy.sbg.ac.at>
List-Id: netdev.vger.kernel.org

Well, so that the patch below should be ok. At least it works for IA32.
I'll make it part of htb tarball for now to make users happy ..
devik

--- ../linux-2.4orig/include/net/pkt_sched.h    Sun Dec  9 21:15:25 2001
+++ include/net/pkt_sched.h     Thu May 16 16:45:00 2002
@@ -221,7 +221,7 @@

 #define PSCHED_EXPORTLIST_2

-#if ~0UL == 0xFFFFFFFF
+#if BITS_PER_LONG <= 32

 #define PSCHED_WATCHER unsigned long




On Thu, 16 May 2002, Thomas 'Dent' Mirlacher wrote:

> --snip/snip
> > Probably the test should be changed. I'm not sure how. How to detect
> > that long is 64 bit in cpp ?
>
> by using BITS_PER_LONG (which is defined in include/asm/types.h)
>
> 	tm
>
> --
> in some way i do, and in some way i don't.
>
>
>
