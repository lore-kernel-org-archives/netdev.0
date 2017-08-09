From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v06 15/36] uapi linux/socket.h: include sys/socket.h in
 user space
Date: Wed, 9 Aug 2017 14:32:55 +0200
Message-ID: <CAK8P3a0-Dx=YXJvTCyR4STUTVOYHJPPgJFqoJ35phL8YdnYREw@mail.gmail.com>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi> <20170806164428.2273-16-mikko.rapeli@iki.fi>
 <20170808230041.GG10552@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Dmitry V. Levin" <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170808230041.GG10552-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 9, 2017 at 1:00 AM, Dmitry V. Levin <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org> wrote:
> On Sun, Aug 06, 2017 at 06:44:06PM +0200, Mikko Rapeli wrote:
>> This libc header has sockaddr definition in user space.
>>
>> Fixes user space compilation errors like these from kernel headers inclu=
ding
>> only linux/socket.h:
>>
>> error: field =E2=80=98ifru_addr=E2=80=99 has incomplete type
>> struct sockaddr ifru_addr;
>> error: field =E2=80=98_sockaddr=E2=80=99 has incomplete type
>> struct sockaddr  _sockaddr;
>> error: invalid application of =E2=80=98sizeof=E2=80=99 to incomplete typ=
e =E2=80=98struct sockaddr=E2=80=99
>>
>> With this following uapi headers now compile in user space:
>>
>> rdma/rdma_user_rxe.h
>> linux/vm_sockets.h
>> linux/ncp_fs.h
>> linux/nfc.h
>> linux/phonet.h
>>

>>
>> +#ifndef __KERNEL__
>> +#include <sys/socket.h>
>> +#endif
>
> This is scary because of infamous libc vs uapi interoperability issues.
> Couldn't we fix affected headers instead?

Yes, I think that would be better. Maybe we can introduce a
'struct __kernel_sockaddr' in include/uapi/linux/socket.h to
go along with __kernel_sa_family_t and __kernel_sockaddr_storage,
and then use those types in the other kernel headers?

       Arnd
