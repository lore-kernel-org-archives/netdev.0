From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: new kmemleak reports (was: Re: [PATCH 0/5] genetlink
 improvements)
Date: Tue, 1 Nov 2016 18:56:30 +0000
Message-ID: <20161101185630.3c7d326f@jkicinski-Precision-T1700>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
        <20161101172840.6d7d6278@jkicinski-Precision-T1700>
        <CAM_iQpVeB+2M1MPxjRx++E=q4mDuo7XQqfQn3-160PqG8bNLdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:18753 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751152AbcKAS4g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 14:56:36 -0400
In-Reply-To: <CAM_iQpVeB+2M1MPxjRx++E=q4mDuo7XQqfQn3-160PqG8bNLdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Nov 2016 11:32:52 -0700, Cong Wang wrote:
> On Tue, Nov 1, 2016 at 10:28 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> > unreferenced object 0xffff8807389cba28 (size 128):
> >   comm "swapper/0", pid 1, jiffies 4294898463 (age 781.332s)
> >   hex dump (first 32 bytes):
> >     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> >     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> >   backtrace:
> >     [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
> >     [<ffffffff84771246>] __kmalloc+0x206/0x5a0
> >     [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
> >     [<ffffffff888d9524>] netlbl_mgmt_genl_init+0x10/0x12
> >     [<ffffffff888d91e8>] netlbl_netlink_init+0x9/0x26
> >     [<ffffffff888d9254>] netlbl_init+0x4f/0x85
> >     [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
> >     [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
> >     [<ffffffff85de7793>] kernel_init+0x13/0x140
> >     [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40  
> 
> Looks like we are missing a kfree(family->attrbuf); on error path,
> but it is not related to Johannes' recent patches.
> 
> Could the attached patch help?
> 
> Thanks.

Still there:

unreferenced object 0xffff88073fb204e8 (size 64):
  comm "swapper/0", pid 1, jiffies 4294898455 (age 88.528s)
  hex dump (first 32 bytes):
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff93decbf8>] kmemleak_alloc+0x28/0x50
    [<ffffffff92771246>] __kmalloc+0x206/0x5a0
    [<ffffffff939e1471>] genl_register_family+0x921/0x1270
    [<ffffffff968d0ecf>] genl_init+0x11/0x43
    [<ffffffff920022b7>] do_one_initcall+0xb7/0x2a0
    [<ffffffff967f9102>] kernel_init_freeable+0x597/0x636
    [<ffffffff93de78b3>] kernel_init+0x13/0x140
    [<ffffffff93e0256a>] ret_from_fork+0x2a/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff

etc.

I'm getting this quite reliably on every boot.
