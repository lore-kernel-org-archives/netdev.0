From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Bug #15196] kmem_cache_create: duplicate cache ccid2_h
Date: Mon, 08 Feb 2010 12:34:54 -0800 (PST)
Message-ID: <20100208.123454.38911094.davem@davemloft.net>
References: <445R0ey9hAI.A.tNB.XozbLB@chimera>
	<20100208071515.GA6473@fancy-poultry.org>
	<201002081204.28039.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: htd-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org, xtfeng-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: rjw-KKrjLPT3xs0@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201002081204.28039.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Date: Mon, 8 Feb 2010 12:04:27 +0100

> Hmm.  The bug is in net/dccp/ccid.c, so it looks like something for the
> networking guys to merge.
> 
> Any chance to send a singed-off version of the patch do David?

Fixes for this are already in my net-2.6 tree, will send them
off to Linus later today, I was waiting for some netfilter
fixes which I just received:

commit 1386be55e32a3c5d8ef4a2b243c530a7b664c02c
Author: Gerrit Renker <gerrit-VsoRXqaLlyfQzY9nttDBhA@public.gmane.org>
Date:   Tue Feb 2 20:16:56 2010 +0000

    dccp: fix auto-loading of dccp(_probe)
    
    This fixes commit (38ff3e6bb987ec583268da8eb22628293095d43b) ("dccp_probe:
    Fix module load dependencies between dccp and dccp_probe", from 15 Jan).
    
    It fixes the construction of the first argument of try_then_request_module(),
    where only valid return codes from the first argument should be returned.
    
    What we do now is assign the result of register_jprobe() to ret, without
    the side effect of the comparison.
    
    Acked-by: Gerrit Renker <gerrit-VsoRXqaLlyfQzY9nttDBhA@public.gmane.org>
    Signed-off-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

commit 8ed030dd0aa400d18c63861c2c6deb7c38f4edde
Author: Gerrit Renker <gerrit-VsoRXqaLlyfQzY9nttDBhA@public.gmane.org>
Date:   Mon Feb 1 02:12:19 2010 +0000

    dccp: fix bug in cache allocation
    
    This fixes a bug introduced in commit de4ef86cfce60d2250111f34f8a084e769f23b16
    ("dccp: fix dccp rmmod when kernel configured to use slub", 17 Jan): the
    vsnprintf used sizeof(slab_name_fmt), which became truncated to 4 bytes, since
    slab_name_fmt is now a 4-byte pointer and no longer a 32-character array.
    
    This lead to error messages such as
     FATAL: Error inserting dccp: No buffer space available
    
     >> kernel: [ 1456.341501] kmem_cache_create: duplicate cache cci
    generated due to the truncation after the 3rd character.
    
    Fixed for the moment by introducing a symbolic constant. Tested to fix the bug.
    
    Signed-off-by: Gerrit Renker <gerrit-VsoRXqaLlyfQzY9nttDBhA@public.gmane.org>
    Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
