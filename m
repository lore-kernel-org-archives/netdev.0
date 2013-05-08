From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: net-next currently not in good shape
Date: Wed, 08 May 2013 16:30:25 -0700
Message-ID: <1368055825.13473.31.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:38857 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653Ab3EHXa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 19:30:28 -0400
Received: by mail-oa0-f50.google.com with SMTP id l10so2775959oag.9
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 16:30:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

net-next is currently lacking following patch and dies at boot time (at
leat on my machines)

This message might help others.

Thanks !


commit 956e46efb2478ebff7a871138458fa8124fd18dd
Author: Chris Mason <clmason@fusionio.com>
Date:   Wed May 8 15:56:28 2013 -0400

    mm/slab: Fix crash during slab init
    
    Commit 8a965b3baa89 ("mm, slab_common: Fix bootstrap creation of kmalloc
    caches") introduced a regression that caused us to crash early during
    boot.  The commit was introducing ordering of slab creation, making sure
    two odd-sized slabs were created after specific powers of two sizes.
    
    But, if any of the power of two slabs were created earlier during boot,
    slabs at index 1 or 2 might not get created at all.  This patch makes
    sure none of the slabs get skipped.
    
    Tony Lindgren bisected this down to the offending commit, which really
    helped because bisect kept bringing me to almost but not quite this one.
    
    Signed-off-by: Chris Mason <chris.mason@fusionio.com>
    Acked-by: Christoph Lameter <cl@linux.com>
    Acked-by: Tony Lindgren <tony@atomide.com>
    Acked-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
    Tested-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
    Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
