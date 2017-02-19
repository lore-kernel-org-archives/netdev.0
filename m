From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: net: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in
 skb_array_produce
Date: Sun, 19 Feb 2017 07:18:27 +0200
Message-ID: <20170219071640-mutt-send-email-mst@kernel.org>
References: <CACT4Y+bs15VR7xjeYhece+0_X5Ss+5FM0w6jpJH0Dbbdu-+qCQ@mail.gmail.com>
 <50038580.20299907.1486634551103.JavaMail.zimbra@redhat.com>
 <20170209200936-mutt-send-email-mst@kernel.org>
 <ce1d4f53-d664-0ee1-cf79-aca66d2d0d00@redhat.com>
 <CACT4Y+Z6hAo6rK59MmE31K-rm4=NveunQGNwA7XcqFTaB08zCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z6hAo6rK59MmE31K-rm4=NveunQGNwA7XcqFTaB08zCQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 18, 2017 at 06:28:39PM +0100, Dmitry Vyukov wrote:
> On Fri, Feb 10, 2017 at 6:17 AM, Jason Wang <jasowang@redhat.com> wrote:
> >
> >
> > On 2017年02月10日 02:10, Michael S. Tsirkin wrote:
> >>
> >> On Thu, Feb 09, 2017 at 05:02:31AM -0500, Jason Wang wrote:
> >>>
> >>> ----- Original Message -----
> >>>>
> >>>> Hello,
> >>>>
> >>>> I've got the following report while running syzkaller fuzzer on mmotm
> >>>> (git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git)
> >>>> remotes/mmotm/auto-latest ee4ba7533626ba7bf2f8b992266467ac9fdc045e:
> >>>>
> >>> [...]
> >>>
> >>>> other info that might help us debug this:
> >>>>
> >>>>   Possible interrupt unsafe locking scenario:
> >>>>
> >>>>         CPU0                    CPU1
> >>>>         ----                    ----
> >>>>    lock(&(&r->consumer_lock)->rlock);
> >>>>                                 local_irq_disable();
> >>>>                                 lock(&(&r->producer_lock)->rlock);
> >>>>                                 lock(&(&r->consumer_lock)->rlock);
> >>>>    <Interrupt>
> >>>>      lock(&(&r->producer_lock)->rlock);
> >>>>
> >>> Thanks a lot for the testing.
> >>>
> >>> Looks like we could address this by using skb_array_consume_bh() instead.
> >>>
> >>> Could you pls verify if the following patch works?
> >>
> >> I think we should use _bh for the produce call as well,
> >> since resizing takes the producer lock.
> >
> > Looks not since irq was disabled during resizing?
> 
> 
> Hello,
> 
> Is there a fix for this that we can pick up?
> This killed 10'000 VMs on our testing infra over the last day. Still
> happening on linux-next.
> 
> Thanks

I posted a fix.  ptr_ring: fix race conditions when resizing
Just reposted.  I'll push into linux-next ASAP.

-- 
MST
