From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH net-next 1/1] driver: tun: Use new macro SOCK_IOC_MAGIC
 instead of literal number 0x89
Date: Wed, 26 Oct 2016 22:10:47 +0800
Message-ID: <CA+6hz4rB5zJDLqhf0bQVhp9=EyZ7kjO3hu-6QtvMmGx-wszNaQ@mail.gmail.com>
References: <1477400179-32200-1-git-send-email-fgao@ikuai8.com> <063D6719AE5E284EB5DD2968C1650D6DB020AC7B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "pabeni@redhat.com" <pabeni@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg202.qq.com ([184.105.206.29]:48627 "EHLO smtpbg202.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754265AbcJZOLA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 10:11:00 -0400
Received: from mail-ua0-f179.google.com (unknown [209.85.217.179])
        by esmtp4.qq.com (ESMTP) with SMTP id 0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 22:10:48 +0800 (CST)
Received: by mail-ua0-f179.google.com with SMTP id b35so5110843uaa.4
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 07:10:49 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB020AC7B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Oct 26, 2016 at 7:12 PM, David Laight <David.Laight@aculab.com> wrote:
> From: fgao@ikuai8.com
>> Sent: 25 October 2016 13:56
>> The current codes use _IOC_TYPE(cmd) == 0x89 to check if the cmd is one
>> socket ioctl command like SIOCGIFHWADDR. But the literal number 0x89 may
>> confuse readers. So create one macro SOCK_IOC_MAGIC like SPI_IOC_MAGIC to
>> enhance the readability.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  drivers/net/tun.c            | 2 +-
>>  include/uapi/linux/sockios.h | 2 ++
>>  2 files changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 9328568..9efd185 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1985,7 +1985,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>>       int le;
>>       int ret;
>>
>> -     if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == 0x89) {
>> +     if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == SOCK_IOC_MAGIC) {
>>               if (copy_from_user(&ifr, argp, ifreq_len))
>>                       return -EFAULT;
>>       } else {
>> diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
>> index 8e7890b..b8f42f2 100644
>> --- a/include/uapi/linux/sockios.h
>> +++ b/include/uapi/linux/sockios.h
>> @@ -24,6 +24,8 @@
>>  #define SIOCINQ              FIONREAD
>>  #define SIOCOUTQ     TIOCOUTQ        /* output queue size (not sent + not acked) */
>>
>> +#define SOCK_IOC_MAGIC       0x89
>> +
>>  /* Routing table calls. */
>>  #define SIOCADDRT    0x890B          /* add routing table entry      */
>>  #define SIOCDELRT    0x890C          /* delete routing table entry   */
>
> Shouldn't these constants be defined in terms of SOCK_IOC_MAGIC?
> And there must be a better name!
>
>         David
>

How about the SOCK_IOC_TYPE or SOCK_IOC_BASE ?
There are ETRAXGPIO_IOCTYPE and HARDWALL_IOCTL_BASE already.

Regards
Feng
