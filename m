From: Tejun Heo <tj@kernel.org>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Wed, 2 Mar 2016 10:45:07 -0500
Message-ID: <20160302154507.GC4282@mtj.duckdns.org>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz>
 <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
 <20160218174427.GG13177@mtj.duckdns.org>
 <56C6EC62.8080107@suse.cz>
 <56C70618.3010902@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Takashi Iwai <tiwai@suse.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56C70618.3010902@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Jiri.

On Fri, Feb 19, 2016 at 01:10:00PM +0100, Jiri Slaby wrote:
> > 1. didn't help, the problem persists. So I haven't applied the patch from 2.
> 
> FWIW I dumped more info about the wq:
> wq->name='hci0' pwq=ffff8800390d7600 wq->dfl_pwq=ffff8800390d5200
> pwq->refcnt=2 pwq->nr_active=0 delayed_works: <nothing>

Can you please print out the same info for all pwq's during shutdown?
It looks like we're leaking pwq refcnt but I can't spot a place where
that could happen on an empty pwq.

Thanks.

-- 
tejun
