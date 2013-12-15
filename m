From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: 3.13-rc1: eth0 hw csum failure on powerpc (bisected)
Date: Sat, 14 Dec 2013 16:40:39 -0800 (PST)
Message-ID: <alpine.DEB.2.11.1312141622230.25690@trent.utfs.org>
References: <alpine.DEB.2.11.1311300156380.31521@trent.utfs.org>
 <alpine.DEB.2.11.1311300210360.31521@trent.utfs.org>
 <alpine.DEB.2.11.1311301314220.31521__48727.6146108799$1385846242$gmane$org@trent.utfs.org>
 <87vbz9pmud.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 LKML <linux-kernel@vger.kernel.org>, Alexander Graf <agraf@suse.de>
To: Andreas Schwab <schwab@linux-m68k.org>, davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <87vbz9pmud.fsf@igel.home>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On Sat, 30 Nov 2013 at 23:05, Andreas Schwab wrote:
> >> > [...]
> >> >  Freeing unused kernel memory: 204K (c06ea000 - c071d000)
> >> >  eth0: hw csum failure
> >> >  CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.0-rc2 #1
> >> >  Call Trace:
> >> 
> >> Btw, full dmesg & .config:  http://nerdbynature.de/bits/3.13-rc1/
> >
> > Oh, this has already been reported earlier this week:
> >
> > https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-November/113584.html
> 
> No solution yet, though, 3.13-rc2 is still broken.

As 3.13-rc3 was still broken, I tried a git-bisect, resulting in:


018c5bba052b3a383d83cf0c756da0e7bc748397 is the first bad commit
commit 018c5bba052b3a383d83cf0c756da0e7bc748397
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Nov 15 21:11:16 2013 -0500

    net: Handle CHECKSUM_COMPLETE more adequately in pskb_trim_rcsum().
    
    Currently pskb_trim_rcsum() just balks on CHECKSUM_COMPLETE packets
    and remarks them as CHECKSUM_NONE, forcing a software checksum
    validation later.
    
    We have all of the mechanics available to fixup the skb->csum value,
    even for complicated fragmented packets, via the helpers
    skb_checksum() and csum_sub().
    
    So just use them.
    
    Based upon a suggestion by Herbert Xu.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 14e295c30c2d2a1164f4eb70aaec821fbe288c01 456c666ebbb355292b683c71c85585fc6d07e852 M      include


And sure enough, today's 3.13-rc3 with only that commit reverted boots 
just fine on this PowerBook G4 system.

Thanks,
Christian
-- 
BOFH excuse #152:

My pony-tail hit the on/off switch on the power strip.
