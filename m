From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 2/2] pktgen: Specify the index of first thread
Date: Wed, 14 Jun 2017 13:29:51 +0200
Message-ID: <20170614132951.2c86d1cf@redhat.com>
References: <1497366289-22255-1-git-send-email-tariqt@mellanox.com>
        <1497366289-22255-3-git-send-email-tariqt@mellanox.com>
        <20170614090922.541cf241@redhat.com>
        <61690488-f20e-6768-e007-bd8b89cc0bf7@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>, brouer@redhat.com
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4188 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751771AbdFNLaG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 07:30:06 -0400
In-Reply-To: <61690488-f20e-6768-e007-bd8b89cc0bf7@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jun 2017 14:10:37 +0300
Tariq Toukan <tariqt@mellanox.com> wrote:

> >> +export L_THREAD="$THREADS + $F_THREAD - 1"
> >> +  
> > 
> > This is sort of bad-shell coding.  This will first get expanded at the
> > usage point.  The way you use it, it will work, because of the for loop
> > uses an expansion like "((xxx))".
> > 
> > If you echo the $L_THREAD variable you will see: "1 + 0 - 1"
> > 
> > IMHO the right thing is to use:
> > 
> >    export L_THREAD=$(( THREADS + F_THREAD - 1 ))
> > 
> > (I tested this also works for dash + ksh + zsh)
> >   
> Thanks, I'll use the suggested command.
> >   
> >> diff --git a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
> >> index d2694a12de61..e5bfe759a0fb 100755
> >> --- a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
> >> +++ b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
> >> @@ -48,7 +48,7 @@ DELAY="0"        # Zero means max speed
> >>   pg_ctrl "reset"
> >>   
> >>   # Threads are specified with parameter -t value in $THREADS
> >> -for ((thread = 0; thread < $THREADS; thread++)); do
> >> +for ((thread = $F_THREAD; thread <= $L_THREAD; thread++)); do
> >>       # The device name is extended with @name, using thread number to
> >>       # make then unique, but any name will do.
> >>       dev=${DEV}@${thread}  
> > 
> > The expansion/use of $L_THREAD only works because "for-loop" expanded
> > it by using ""(("" arithmetic evaluation.
> >   
> After changing the one above, this one should still be OK, right?

Yes, this part is still correct.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
