From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next] openvswitch: change the data type of error
 status to atomic_long_t
Date: Tue, 9 Sep 2014 08:29:56 +0800
Message-ID: <CAJFZqHzWa=gB8b653KgmGZTpNv83KhAZ3VBYvd+VjchmCkiCbQ@mail.gmail.com>
References: <1410001571-13338-1-git-send-email-roy.qing.li@gmail.com>
	<CALnjE+o121kh+hEtEsSLJqBw68dy=epEsXGVDN5wv+4g1xph+g@mail.gmail.com>
	<CAJFZqHwK=5iXxBP+SgcLtub=HSkTt9Pd6LU2_Tjn9qTxbQd3SA@mail.gmail.com>
	<CALnjE+pTVVr3dQTnUZqB4vQ=MjhyJ1C859Rkjmf7JOGzVVsb5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:58965 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940AbaIIA35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 20:29:57 -0400
Received: by mail-qc0-f179.google.com with SMTP id o8so436043qcw.10
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 17:29:56 -0700 (PDT)
In-Reply-To: <CALnjE+pTVVr3dQTnUZqB4vQ=MjhyJ1C859Rkjmf7JOGzVVsb5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 9, 2014 at 6:26 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Sun, Sep 7, 2014 at 2:24 AM, Li RongQing <roy.qing.li@gmail.com> wrote:
>> On Sun, Sep 7, 2014 at 11:44 AM, Pravin Shelar <pshelar@nicira.com> wrote:
>>>> The operation of atomic maybe faster than spin lock.
>>>
>>> What is reason for this change?
>>
>> 1.  The operation of atomic maybe faster than spin lock
>> 2.  I did not find that tx_dropped/tx_error/.. is protected by spin
>> lock under net dir,
>> sometime tx_dropped is atomic_long_t; sometime it is percpu variable;
>> sometime it is
>> u64,but does not need to protect.
>>
>
> These are error counter and the access is not performance sensitive
> code. So I do not see obvious need to optimize it. Do you have any
> performance number for this patch?


I have no performance number, and did not know how to get the performance
number, since I did not know how to trigger the error packet continually.

But I think  atomic is suitable for this condition, it maybe
over-skill to use a spin
lock to protect a single variable, and using atomic can save a spin lock space.


-Roy
