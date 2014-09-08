From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH][net-next] openvswitch: change the data type of error
 status to atomic_long_t
Date: Mon, 8 Sep 2014 15:26:13 -0700
Message-ID: <CALnjE+pTVVr3dQTnUZqB4vQ=MjhyJ1C859Rkjmf7JOGzVVsb5w@mail.gmail.com>
References: <1410001571-13338-1-git-send-email-roy.qing.li@gmail.com>
	<CALnjE+o121kh+hEtEsSLJqBw68dy=epEsXGVDN5wv+4g1xph+g@mail.gmail.com>
	<CAJFZqHwK=5iXxBP+SgcLtub=HSkTt9Pd6LU2_Tjn9qTxbQd3SA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:36110 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754843AbaIHW0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 18:26:14 -0400
Received: by mail-ig0-f170.google.com with SMTP id h3so3519845igd.5
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 15:26:13 -0700 (PDT)
In-Reply-To: <CAJFZqHwK=5iXxBP+SgcLtub=HSkTt9Pd6LU2_Tjn9qTxbQd3SA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 7, 2014 at 2:24 AM, Li RongQing <roy.qing.li@gmail.com> wrote:
> On Sun, Sep 7, 2014 at 11:44 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>>> The operation of atomic maybe faster than spin lock.
>>
>> What is reason for this change?
>
> 1.  The operation of atomic maybe faster than spin lock
> 2.  I did not find that tx_dropped/tx_error/.. is protected by spin
> lock under net dir,
> sometime tx_dropped is atomic_long_t; sometime it is percpu variable;
> sometime it is
> u64,but does not need to protect.
>

These are error counter and the access is not performance sensitive
code. So I do not see obvious need to optimize it. Do you have any
performance number for this patch?
