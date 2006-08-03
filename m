From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 3 Aug 2006 22:29:11 +0400
Message-ID: <20060803182911.GA8692@2ka.mipt.ru>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru> <44D20A2F.3090005@arndnet.de> <20060803150330.GB12915@2ka.mipt.ru> <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl> <20060803151631.GA14774@2ka.mipt.ru> <20060803154125.GA9745@2ka.mipt.ru> <44D23BC3.7040707@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47330 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S964829AbWHCS3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 14:29:32 -0400
To: Arnd Hannemann <arnd@arndnet.de>
Content-Disposition: inline
In-Reply-To: <44D23BC3.7040707@arndnet.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 08:09:07PM +0200, Arnd Hannemann (arnd@arndnet.de) wrote:
> Evgeniy Polyakov schrieb:
> > On Thu, Aug 03, 2006 at 07:16:31PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> >>>> then skb_alloc adds a little
> >>>> (sizeof(struct skb_shared_info)) at the end, and this ends up
> >>>> in 32k request just for 9k jumbo frame.
> >>> Strange, why this skb_shared_info cannon be added before first alignment? 
> >>> And what about smaller frames like 1500, does this driver behave similar 
> >>> (first align then add)?
> >> It can be.
> >> Could attached  (completely untested) patch help?
> > 
> > Actually this patch will not help, this new one could.
> > 
> 
> I applied the attached pachted. And got this output:
> 
> > Intel(R) PRO/1000 Network Driver - bufsz 13762
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16058
> > Intel(R) PRO/1000 Network Driver - bufsz 15894
> > Intel(R) PRO/1000 Network Driver - bufsz 15730
> > Intel(R) PRO/1000 Network Driver - bufsz 15566
> > Intel(R) PRO/1000 Network Driver - bufsz 15402
> > Intel(R) PRO/1000 Network Driver - bufsz 15238
> > Intel(R) PRO/1000 Network Driver - bufsz 15074
> > Intel(R) PRO/1000 Network Driver - bufsz 14910
> > Intel(R) PRO/1000 Network Driver - bufsz 14746
> > Intel(R) PRO/1000 Network Driver - bufsz 14582
> > Intel(R) PRO/1000 Network Driver - bufsz 14418
> > Intel(R) PRO/1000 Network Driver - bufsz 14254
> > Intel(R) PRO/1000 Network Driver - bufsz 14090
> > Intel(R) PRO/1000 Network Driver - bufsz 13926
> > Intel(R) PRO/1000 Network Driver - bufsz 13762
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16058
> > Intel(R) PRO/1000 Network Driver - bufsz 15894
> > Intel(R) PRO/1000 Network Driver - bufsz 15730
> > Intel(R) PRO/1000 Network Driver - bufsz 15566
> > Intel(R) PRO/1000 Network Driver - bufsz 15402
> > Intel(R) PRO/1000 Network Driver - bufsz 15238
> > Intel(R) PRO/1000 Network Driver - bufsz 15074
> > Intel(R) PRO/1000 Network Driver - bufsz 14910
> > Intel(R) PRO/1000 Network Driver - bufsz 14746
> > Intel(R) PRO/1000 Network Driver - bufsz 14582
> > Intel(R) PRO/1000 Network Driver - bufsz 14418
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> > Intel(R) PRO/1000 Network Driver - bufsz 16222
> 
> I'm a bit puzzled that there are so much allocations. However the patch
> seems to work. (at least not obviously breaks things for me yet)

Very strange output actually - comments in the code say that frame size
can not exceed 0x3f00, but in this log it is much more than 16128 and
that is after sizeof(struct skb_shared_info) has been removed...
Could you please remove debug output and run some network stress test in
parallel with high disk/memory activity to check if that does not break
your system and watch /proc/slabinfo for 16k and 32k sized pools.

> Best regards
> Arnd


-- 
	Evgeniy Polyakov
