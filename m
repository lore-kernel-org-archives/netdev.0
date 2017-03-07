From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH net 0/3] rds: tcp: fix various rds-tcp issues during netns
 create/delete sequences
Date: Tue, 7 Mar 2017 09:28:15 +0100
Message-ID: <CACT4Y+aKp6LPUSR4yivWKMFjC1QeC7qbqiQ7hFCwj+RhDt5Msw@mail.gmail.com>
References: <cover.1488645926.git.sowmini.varadhan@oracle.com> <125d878b-ac8d-dcfd-d1ff-1b1a84cff5a5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>, rds-devel@oss.oracle.com
To: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:35400 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755192AbdCGIxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 03:53:52 -0500
Received: by mail-ua0-f174.google.com with SMTP id q7so160444436uaf.2
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 00:53:05 -0800 (PST)
In-Reply-To: <125d878b-ac8d-dcfd-d1ff-1b1a84cff5a5@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 7, 2017 at 2:04 AM, santosh.shilimkar@oracle.com
<santosh.shilimkar@oracle.com> wrote:
> On 3/4/17 8:57 AM, Sowmini Varadhan wrote:
>>
>> Dmitry Vyukov reported some syszkaller panics during netns deletion.
>>
>> While I have not been able to reproduce those exact panics, my attempts
>> to do so uncovered a few other problems, which are fixed patch 2 and
>> patch 3 of this patch series. In addition, as mentioned in,
>>  https://www.spinics.net/lists/netdev/msg422997.html
>> code-inspection points that the rds_connection needs to take an explicit
>> refcnt on the struct net so that it is held down until all cleanup is
>> completed for netns removal, and this is fixed by patch1.
>>
> Hopefully Dmitry can try the series and see if it fixes the issue(s).
> The fixes looks good to me.
>
> FWIW, Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>


I've applied the patches for testing. I've seen the reported crashes
only few times, so it won't provide a good testing. But at least it
can detect any regressions.
