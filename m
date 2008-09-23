From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Machine Check Exception Re: NetDev! Please help!
Date: Tue, 23 Sep 2008 11:57:08 +0000
Message-ID: <20080923115708.GC4692@ff.dom.local>
References: <48D67239.9040006@gmail.com> <48D7385D.40107@bigtelecom.ru> <20080922065339.GA4399@ff.dom.local> <48D76813.9000603@bigtelecom.ru> <20080922112452.GB5314@ff.dom.local> <48D79709.80400@bigtelecom.ru> <20080922172349.GA2545@ami.dom.local> <48D89E0C.9040407@bigtelecom.ru> <20080923092504.GB4692@ff.dom.local> <48D8C695.2020302@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:55183 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbYIWL5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 07:57:16 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1588362ugf.37
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 04:57:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48D8C695.2020302@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 02:36:05PM +0400, Badalian Vyacheslav wrote:
> 
> > 2) Non-default qdiscs (any qdiscs added with tc): there is only one
> > root qdisc (with its tree) as before, dequeued to all tx queues (if
> > available). Since there is only one qdisc lock, and additional flag
> > preventing other processes to run the qdisc at the same time, there
> > is not so much advantage of SMP, except on tx locking. All previous
> > tc configs should work without changes (except sch_prio and sch_rr
> > used for multiqueuing, replaced by sch_multiq and act_skbedit now).
> > Probably in some cases adding sch_multiq to a tree for separating
> > qdisc queues per tx queues could be useful.
> >   
> Very thanks for detailed information!
> Yeh! Its sound great for me. I also can stress test this feature in our
> network if you will needed it.

Actually, I don't use these things too much, but I guess, you'll need
this more. Main issues were tested and fixed, but there could be always
some details not used, not noticed or not reported until you decide to
use this.

> 
> Only i have 2 question ...
> 
> 1. If kernel use default situation (no tc user create rules, simple
> autocreate by network card driver/module) its will normal work with
> traffic what must delivered "as is" (not shape)... like IPTV or other
> multicast/unicast video stream...
> If i understand logic
> we have 8 cpu/core and 4 TX queue and 4 RX... one cpu linked to 1
> TX/RX.... but if 1 cpu is burned by some process - this cpu will send
> its packet later when other cpu and packet is shape... but streams must
> go packet by packet to receive device... I understand that it simple
> need use hash function for TX queue, but if i understand - RX can't
> separate packets to different queues (its doing by hardware?) by hash
> function and packets may shape in rx stage because one CPU get it letter
> when nedded?
> I do not wish to spend your time... only say if it will work normal by
> default and i will sleep easy :)

Yes, I'm not sure I understand question, but I think you shouldn't
expect too much, at least in 2.6.27. There is many work now in drivers
around this multiqueing (and RX hashing), which should be available in
next kernels, but I'm not tracking this too much... Anyway, with the
basic support (which really isn't common for drivers in 2.6.27 yet),
this separation is done only for TX just before enqueuing.

> 
> 2. I can locate module like sch_multiq at last 2.6.27-rc tree and not
> have information of it in google... I need to know only one thing - what
> params for hashing was planned for it?

sch_multiq doesn't use any params for hashing now - it uses mapping
in packets to separate them to different bands/queues. So, by default
it'll respect common hashing. You can change this using any filter with
act_skbedit (Documentation/networking/multiqueue.txt).

> Thanks and thanks again! And again sorry for my English.
Don't worry, English should understand...

Jarek P.
