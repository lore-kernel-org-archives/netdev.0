From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] vxlan: Use RCU apis to access sk_user_data.
Date: Tue, 24 Sep 2013 09:25:33 -0700
Message-ID: <CALnjE+qyb7yeXMogv0JE8HTuUm26S1ZJqeav-Oqhfff9ZqUgpA@mail.gmail.com>
References: <1380038979-24035-1-git-send-email-pshelar@nicira.com>
	<1380039366.3165.92.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:33250 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753965Ab3IXQZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:25:35 -0400
Received: by mail-qe0-f46.google.com with SMTP id x7so3278363qeu.19
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:25:34 -0700 (PDT)
In-Reply-To: <1380039366.3165.92.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 9:16 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-09-24 at 09:09 -0700, Pravin B Shelar wrote:
>> Use of RCU api makes vxlan code easier to understand.  It also
>> fixes bug due to missing ACCESS_ONCE() on sk_user_data dereference.
>> In rare case without ACCESS_ONCE() compiler might omit vs on
>> sk_user_data dereference. Compiler can use vs as alias for
>> sk->sk_user_data, resulting in multiple sk_user_data dereference
>> in rcu read context which could change.
>>
>> CC: Jesse Gross <jesse@nicira.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>> v2:
>> Use RCU_INIT_POINTER
>> ---
>>  drivers/net/vxlan.c |   11 ++++-------
>>  include/net/sock.h  |    2 ++
>>  2 files changed, 6 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index d1292fe..1fae0d6 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -1,4 +1,4 @@
>> -/*
>> + /*
>>   * VXLAN: Virtual eXtensible Local Area Network
>>   *
>
>
> extra space ?
>
right, I missed that.
