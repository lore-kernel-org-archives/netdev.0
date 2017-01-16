From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH V2] audit: log 32-bit socketcalls
Date: Mon, 16 Jan 2017 15:38:33 -0500
Message-ID: <CAHC9VhQwVOQ+-iZ1iC-efVvCUadMCdRJS60wqgUQWgExL51yEw@mail.gmail.com>
References: <dd937da01da72da9277e44ed79abd1f4618c14c5.1484297765.git.rgb@redhat.com>
 <20170116.132745.1831536278596554491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: rgb@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-audit@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:36810 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750900AbdAPUif (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 15:38:35 -0500
Received: by mail-vk0-f65.google.com with SMTP id n19so9578391vkd.3
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 12:38:35 -0800 (PST)
In-Reply-To: <20170116.132745.1831536278596554491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 1:27 PM, David Miller <davem@davemloft.net> wrote:
> From: Richard Guy Briggs <rgb@redhat.com>
> Date: Fri, 13 Jan 2017 04:51:48 -0500
>
>> diff --git a/include/linux/audit.h b/include/linux/audit.h
>> index 9d4443f..43d8003 100644
>> --- a/include/linux/audit.h
>> +++ b/include/linux/audit.h
>> @@ -387,6 +387,18 @@ static inline int audit_socketcall(int nargs, unsigned long *args)
>>               return __audit_socketcall(nargs, args);
>>       return 0;
>>  }
>> +static inline int audit_socketcall_compat(int nargs, u32 *args)
>> +{
>
> Please put an empty line between function definitions.

David, assuming Richard makes your requested changes, any objection if
I merge this via the audit tree instead of the netdev tree?  It's a
bit easier for us from a testing perspective this way ...

>> +     if (unlikely(!audit_dummy_context())) {
>> +             int i;
>> +             unsigned long a[AUDITSC_ARGS];
>
> Please order local variable declarations from longest to shortest line.
>
>> +
>> +             for (i=0; i<nargs; i++)
>
> Please put a space around operators such as "=" and "<".
>
>> +                     a[i] = (unsigned long)args[i];
>> +             return __audit_socketcall(nargs, a);
>> +     }
>> +     return 0;
>> +}
>>  static inline int audit_sockaddr(int len, void *addr)
>
> Again, empty line between function definitions please.
>
>> @@ -781,14 +782,24 @@ COMPAT_SYSCALL_DEFINE5(recvmmsg, int, fd, struct compat_mmsghdr __user *, mmsg,
>>
>>  COMPAT_SYSCALL_DEFINE2(socketcall, int, call, u32 __user *, args)
>>  {
>> +     unsigned int len;
>>       int ret;
>> -     u32 a[6];
>> +     u32 a[AUDITSC_ARGS];
>>       u32 a0, a1;
>
> Longest to shortest line for local variable declarations please.
>
> --
> Linux-audit mailing list
> Linux-audit@redhat.com
> https://www.redhat.com/mailman/listinfo/linux-audit



-- 
paul moore
www.paul-moore.com
