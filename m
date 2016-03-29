From: Wei-Ning Huang <wnhuang@google.com>
Subject: Re: [PATCH] mwifiex: add __GFP_REPEAT to skb allocation call
Date: Tue, 29 Mar 2016 17:27:16 +0800
Message-ID: <CABicQ-UJ1kniq6m86QcyVZBPznvNexfrUrTk3A_=GmZy69hvCA@mail.gmail.com>
References: <1459226840-36287-1-git-send-email-wnhuang@chromium.org>
	<87vb45brxc.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Wireless <linux-wireless@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Sameer Nanda <snanda@google.com>, netdev@vger.kernel.org,
	Sonny Rao <sonnyrao@chromium.org>,
	Douglas Anderson <dianders@chromium.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:33700 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756531AbcC2J1S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 05:27:18 -0400
Received: by mail-ob0-f172.google.com with SMTP id x3so7499521obt.0
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 02:27:17 -0700 (PDT)
In-Reply-To: <87vb45brxc.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding some chromium devs to the thread.

In, http://lxr.free-electrons.com/source/mm/page_alloc.c#L3152

The default mm retry allocation when 'order <=3D
PAGE_ALLOC_COSTLY_ORDER' of gfp_mask contains __GFP_REPEAT.
PAGE_ALLOC_COSTLY_ORDER is defined to be 3. On systems with page size
=3D 4K, this means memory compaction and retry is only done when the
size of allocation is <=3D 32K
In mwifiex, the allocation size is 64K. When we have system with
memory fragmentation and allocation failed, there will be no retry.
This is why we need to add __GFP_REPEAT here to allow the system to
perform memory compaction and retry allocation.

Maybe Amit@marvell can comment on if this is a good fix on this issue.
I'm also aware that marvell is the progress of implementing
scatter/gatter for mwifiex, which can also fix the issue.

Wei-Ning

On Tue, Mar 29, 2016 at 4:37 PM, Kalle Valo <kvalo@codeaurora.org> wrot=
e:
> Wei-Ning Huang <wnhuang@chromium.org> writes:
>
>> "single skb allocation failure" happens when system is under heavy
>> memory pressure.  Add __GFP_REPEAT to skb allocation call so kernel
>> attempts to reclaim pages and retry the allocation.
>>
>> Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
>
> Is this really a proper way to fix the issue? This is the first time =
I'm
> hearing about the flag and there isn't even a single user in
> drivers/net. I would like to get confirmation from others that
> __GFP_REPEAT is really ok to use in a wireless driver before I can ta=
ke
> this.
>
> --
> Kalle Valo



--=20
Wei-Ning Huang, =E9=BB=83=E5=81=89=E5=AF=A7 | Software Engineer, Google=
 Inc., Taiwan |
wnhuang@google.com | Cell: +886 910-380678
