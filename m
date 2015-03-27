From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] fib: move fib_rules_cleanup_ops() under rtnl lock
Date: Fri, 27 Mar 2015 14:17:12 -0700
Message-ID: <CAHA+R7Puss-BUG0gFdw+FnbaiXE6Rx=FJ8ccJ2JyJdNMz7H2bQ@mail.gmail.com>
References: <1427403769-31208-1-git-send-email-xiyou.wangcong@gmail.com>
	<55147E5D.2070600@redhat.com>
	<CAHA+R7P4-y4o5WuUwzfwd+LrrkdRdo2=UfXzYdgTrJ63qkaTVg@mail.gmail.com>
	<55148576.1010303@redhat.com>
	<CAHA+R7Na0BO=rQwFNy-M6pa=TfUXuMDiiwNzsevPpt5CUF=mqQ@mail.gmail.com>
	<CAHA+R7MKNcOOiAsV7iQ2WT=sXCmaM0FuJ0OuY_S8reP2K8hN=w@mail.gmail.com>
	<55149A99.6040704@redhat.com>
	<20150327120135.GC12265@casper.infradead.org>
	<CAHA+R7MJTz1-F2v1c+ZEkVQ_JX0Ey5dGAmCjR_N8rvVPbuM0Tg@mail.gmail.com>
	<5515C6C4.4080200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34053 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbbC0VRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 17:17:13 -0400
Received: by igcau2 with SMTP id au2so38843304igc.1
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 14:17:12 -0700 (PDT)
In-Reply-To: <5515C6C4.4080200@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 2:08 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
>
> This locking issue, if present, is separate from the original issue you
> reported.  I'm going to submit a patch to fix your original issue and you
> can chase this locking issue down separately if that is what you want to do.

Make sure you really read my changelog, in case you don't:

"
ops->rules_list is protected by rtnl_lock + RCU,
there is no reason to take net->rules_mod_lock here.
Also, ops->delete() needs to be called with rtnl_lock
too. The problem exists before, just it is exposed
recently due to the fib local/main table change.
"

Sometimes people more easily miss the most obvious thing,
which is the first sentences of my changelog.


> This way if someone ever decides to backport it they can actually fix the
> original issue without pulling in speculative fixes for the rtnl locking
> problem since we were already holding the lock for fib4.
>

Backporting is my guess of Thomas's point, you go too far beyond it.

Also, you have a different definition of original issue.
