From: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Thu, 3 Mar 2016 10:12:01 +0100
Message-ID: <56D7FFE1.90900@suse.cz>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz>
 <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
 <20160218174427.GG13177@mtj.duckdns.org> <56C6EC62.8080107@suse.cz>
 <56C70618.3010902@suse.cz> <20160302154507.GC4282@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
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
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160302154507.GC4282-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 03/02/2016, 04:45 PM, Tejun Heo wrote:
> On Fri, Feb 19, 2016 at 01:10:00PM +0100, Jiri Slaby wrote:
>>> 1. didn't help, the problem persists. So I haven't applied the patch from 2.
>>
>> FWIW I dumped more info about the wq:
>> wq->name='hci0' pwq=ffff8800390d7600 wq->dfl_pwq=ffff8800390d5200
>> pwq->refcnt=2 pwq->nr_active=0 delayed_works: <nothing>
> 
> Can you please print out the same info for all pwq's during shutdown?
> It looks like we're leaking pwq refcnt but I can't spot a place where
> that could happen on an empty pwq.

I have not done that yet, but today, I see:
destroy_workqueue: name='req_hci0' pwq=ffff88002f590300
wq->dfl_pwq=ffff88002f591e00 pwq->refcnt=2 pwq->nr_active=0 delayed_works:
   pwq 12: cpus=0-1 node=0 flags=0x4 nice=-20 active=0/1
     in-flight: 18568:wq_barrier_func

thanks,
-- 
js
suse labs
