From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Fri, 18 Mar 2016 16:52:31 -0400
Message-ID: <20160318205231.GO20028@mtj.duckdns.org>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz>
 <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
 <20160218174427.GG13177@mtj.duckdns.org>
 <56C6EC62.8080107@suse.cz>
 <56C70618.3010902@suse.cz>
 <20160302154507.GC4282@mtj.duckdns.org>
 <56D7FFE1.90900@suse.cz>
 <20160311171205.GB24046@htj.duckdns.org>
 <56EA9C4D.2080803@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Takashi Iwai <tiwai-IBi9RG/b67k@public.gmane.org>
To: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <56EA9C4D.2080803-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, Jiri.

On Thu, Mar 17, 2016 at 01:00:13PM +0100, Jiri Slaby wrote:
> >> I have not done that yet, but today, I see:
> >> destroy_workqueue: name='req_hci0' pwq=ffff88002f590300
> >> wq->dfl_pwq=ffff88002f591e00 pwq->refcnt=2 pwq->nr_active=0 delayed_works:
> >>    pwq 12: cpus=0-1 node=0 flags=0x4 nice=-20 active=0/1
> >>      in-flight: 18568:wq_barrier_func
> > 
> > So, this means that there's flush_work() racing against workqueue
> > destruction, which can't be safe. :(
> 
> But I cannot trigger the WARN_ONs in the attached patch, so I am
> confused how this can happen :(. (While I am still seeing the destroy
> WARNINGs.)

So, no operations should be in progress when destroy_workqueue() is
called.  If somebody was flushing a work item, the flush call must
have returned before destroy_workqueue() was invoked, which doesn't
seem to be the case here.  Can you trigger BUG_ON() or sysrq-t when
the above triggers?  There must be a task which is flushing a work
item there and it shouldn't be difficult to pinpoint what's going on
from it.

Thanks.

-- 
tejun
