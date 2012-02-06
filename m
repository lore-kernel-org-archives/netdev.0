From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v1, kernel version 3.2.1] rtnetlink workaround around the
 skb buff size issue
Date: Mon, 6 Feb 2012 19:52:52 +0100
Message-ID: <CAGsizzLJ27jmX8darnuUX5+B9zr3N+DM-+Uwdk6MrTPO8j_sug@mail.gmail.com>
References: <20120203.192933.510206531351047222.davem@davemloft.net>
 <C5551D9AAB213A418B7FD5E4A6F30A0702F7F86F@ORSMSX106.amr.corp.intel.com>
 <CAGsizzLFoXdUQrA-WtdRq4FDdnDNnevyK6HCRmrT2joUV=ZRXg@mail.gmail.com>
 <20120206.101517.1598607878740481170.davem@davemloft.net> <1328547366.2220.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, gregory.v.rose@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328547366.2220.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/2/6 Eric Dumazet <eric.dumazet@gmail.com>:
> Le lundi 06 f=C3=A9vrier 2012 =C3=A0 10:15 -0500, David Miller a =C3=A9=
crit :
>> From: =C5=A0tefan Gula <steweg@ynet.sk>
>> Date: Mon, 6 Feb 2012 09:53:28 +0100
>>
>> > If I try to request for it, it will eventually fail with a lot of
>> > records even with filtering...
>>
>> Then the user can loop increasing the buffer size until the netlink
>> request succeeds.
>>
>> It is not a problem.
>
> Actually we always truncate message in netlink_recvmsg()
>
> We could use a MSG_NOPARTIAL flag in netlink_recvmsg() so that user c=
an
> avoid the MSG_PEEK operation to fetch next message length.
>
> (Ie not consume/copy skb if user buffer is too small to hold full
> message, and only return the needed length)
>
>
>
Not sure if this will work. I tried to implement this by the way of
sending one request from user-space to kernel and using NLM_F_MULTI
messages per record to receive the data back from kernel. The problem
was that if I went somewhere beyond 700 messages/records. I get EAGAIN
error code from kernel while trying to write to netlink socket. On the
other hand iproute code was getting error on recvmsg() that buffer is
full. The messages was only 40B long so they should always be able to
fit the 16k buffer used. So I end up with not being able to write nor
read from the socket -> not really sure why. If I introduce paging to
this, so kernel will put only limited number of records (in my case it
was 10) per one request and wait for another request message to
continue... this approach has done job for me. So maybe a good thing
here would be to post the whole code, including rtnetlink part,
macvlan part, iproute part and let you guys check, if you want. Do you
agree?
