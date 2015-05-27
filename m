From: Sorin Dumitru <sorin@returnze.ro>
Subject: Re: [PATCH net-next] vxlan: release lock after each bucket in vxlan_cleanup
Date: Wed, 27 May 2015 21:09:39 +0300
Message-ID: <CALh4rZoiRw8ng6X3+=qyYJ1K4BtQPJM7QwMKKBvazp4EkA27_Q@mail.gmail.com>
References: <1432626124-24676-1-git-send-email-sorin@returnze.ro>
	<CAHA+R7Md7vGJj_6e8P7iB3j-gaax6H37OQ_9N26KUwjgbWHz_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sorin Dumitru <sdumitru@ixiacom.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:32775 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbE0SJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:09:43 -0400
Received: by lbcue7 with SMTP id ue7so13028043lbc.0
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 11:09:39 -0700 (PDT)
In-Reply-To: <CAHA+R7Md7vGJj_6e8P7iB3j-gaax6H37OQ_9N26KUwjgbWHz_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 8:44 PM, Cong Wang <cwang@twopensource.com> wrote:
> On Tue, May 26, 2015 at 12:42 AM, Sorin Dumitru <sorin@returnze.ro> wrote:
>> We're seeing some softlockups from this function when there
>> are a lot fdb entries on a vxlan device. Taking the lock for
>> each bucket instead of the whole table is enough to fix that.
>>
>
> Hmm, then the spinlock could be moved into each bucket, right?

Yes, it could, but I'm not sure if it will benefit us too much. I didn't see
too much contention on this lock while adding and removing fdb entries.
