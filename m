From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next] openvswitch: change the data type of error
 status to atomic_long_t
Date: Mon, 8 Sep 2014 19:23:11 +0800
Message-ID: <CAJFZqHzeCCRJgrx5dTuLBMtfNf4QKkxU77PJXNXWuYcoBFuZWw@mail.gmail.com>
References: <1410001571-13338-1-git-send-email-roy.qing.li@gmail.com>
	<CALnjE+o121kh+hEtEsSLJqBw68dy=epEsXGVDN5wv+4g1xph+g@mail.gmail.com>
	<CAJFZqHwK=5iXxBP+SgcLtub=HSkTt9Pd6LU2_Tjn9qTxbQd3SA@mail.gmail.com>
	<20140907.161720.168413856991894569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pravin Shelar <pshelar@nicira.com>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:64613 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbaIHLXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 07:23:12 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so5255343qgd.5
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 04:23:11 -0700 (PDT)
In-Reply-To: <20140907.161720.168413856991894569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 8, 2014 at 7:17 AM, David Miller <davem@davemloft.net> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> Date: Sun, 7 Sep 2014 17:24:11 +0800
>
>> 2.  I did not find that tx_dropped/tx_error/.. is protected by spin
>> lock under net dir,
>> sometime tx_dropped is atomic_long_t; sometime it is percpu variable;
>> sometime it is
>> u64,but does not need to protect.
>
> If it is only modified in ->ndo_start_xmit() then it is protected by
> the per-queue TX lock, as ->ndo_start_xmit() is always invoked with
> it held (except in LLTX drivers of course).


But reading tx_dropped is in process context, and maybe break by interrupt or
soft interrupt,  and no lock protect, or not the same lock protect.

-Roy
