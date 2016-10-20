From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: fix a race between netvsc_send()
 and netvsc_init_buf()
Date: Thu, 20 Oct 2016 14:03:00 -0400 (EDT)
Message-ID: <20161020.140300.122827393647670926.davem@davemloft.net>
References: <1476885181-3456-1-git-send-email-vkuznets@redhat.com>
        <BLUPR0301MB2098D6A07F0D465E63988D9FCCD50@BLUPR0301MB2098.namprd03.prod.outlook.com>
        <8737jr1k07.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sthemmin@microsoft.com, netdev@vger.kernel.org,
        devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
        kys@microsoft.com, haiyangz@microsoft.com
To: vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8737jr1k07.fsf@vitty.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Thu, 20 Oct 2016 10:51:04 +0200

> Stephen Hemminger <sthemmin@microsoft.com> writes:
> 
>> Do we need ACCESS_ONCE() here to avoid check/use issues?
>>
> 
> I think we don't: this is the only place in the function where we read
> the variable so we'll get normal read. We're not trying to syncronize
> with netvsc_init_buf() as that would require locking, if we read stale
> NULL value after it was already updated on a different CPU we're fine,
> we'll just return -EAGAIN.

The concern is if we race with netvsc_destroy_buf() and this pointer
becomes NULL after the test you are adding.
