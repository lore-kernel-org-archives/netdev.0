From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH] sctp: fix use-after-free in pr_debug statement
Date: Tue, 12 Jan 2016 09:41:18 +0100
Message-ID: <CACT4Y+Z+f4DQRQo0zuH8+7q799dJuGFtjmak7tOMx_TWdrX3Kw@mail.gmail.com>
References: <566AF20F.9060504@gmail.com> <51dffdfdb37c240ff7e9b0b2a93433f217fa4d2c.1452257700.git.marcelo.leitner@gmail.com>
 <20160111.171345.1807630667848434364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37087 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbcALIlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 03:41:39 -0500
Received: by mail-wm0-f42.google.com with SMTP id f206so307616383wmf.0
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 00:41:39 -0800 (PST)
In-Reply-To: <20160111.171345.1807630667848434364.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 11:13 PM, David Miller <davem@davemloft.net> wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Fri,  8 Jan 2016 11:00:54 -0200
>
>> Dmitry Vyukov reported a use-after-free in the code expanded by the
>> macro debug_post_sfx, which is caused by the use of the asoc pointer
>> after it was freed within sctp_side_effect() scope.
>>
>> This patch fixes it by allowing sctp_side_effect to clear that asoc
>> pointer when the TCB is freed.
>>
>> As Vlad explained, we also have to cover the SCTP_DISPOSITION_ABORT case
>> because it will trigger DELETE_TCB too on that same loop.
>>
>> Also, there were places issuing SCTP_CMD_INIT_FAILED and ASSOC_FAILED
>> but returning SCTP_DISPOSITION_CONSUME, which would fool the scheme
>> above. Fix it by returning SCTP_DISPOSITION_ABORT instead.
>>
>> The macro is already prepared to handle such NULL pointer.
>>
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>
> Applied, thank you.


Tested with this patch for half a day. I did not see any reports
related to pr_debug. Let's consider this as fixed.
Thanks!
