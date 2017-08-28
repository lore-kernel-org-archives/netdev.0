From: Bassam Alsanie <bassam.alsanie@gmail.com>
Subject: Re: Get ARP/ND tables from kernel
Date: Mon, 28 Aug 2017 14:34:18 -0700
Message-ID: <CAJW__L=K=QzPNW7f9YP8uvwQBu_J7Thme2XVsbw+Eb+3r1cYXw@mail.gmail.com>
References: <CAJW__LkW10SWRmEKP_0YxjbVHjUYqJFPKsKn-52D1ucF+HH9uQ@mail.gmail.com>
 <E0D909EE5BB15A4699798539EA149D7F07796D3C@ORSMSX103.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:35365 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdH1VeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 17:34:19 -0400
Received: by mail-qt0-f169.google.com with SMTP id x36so7907532qtx.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 14:34:19 -0700 (PDT)
In-Reply-To: <E0D909EE5BB15A4699798539EA149D7F07796D3C@ORSMSX103.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PJ,
Thank you. strace is really gonna help :)
It seem using Netlink (NETLINK_ROUTE) interface is the way to get the
arp/tables form kernel programmatically.

Thank you,
Bassam

On Sun, Aug 27, 2017 at 7:53 PM, Waskiewicz Jr, Peter
<peter.waskiewicz.jr@intel.com> wrote:
> On 8/27/17 9:25 PM, Bassam Alsanie wrote:
>> Hello everyone,
>> I looking into a good way (stable and compatible with large number of
>> distros) to get the arp/nd cache from kernel to user space, for both
>> IP4 and IP6.
>>
>> It seem IOCTL (SIOCGARP) can't do that, you can only get MAC address
>> from provided IP address. But IOCTL can't give the the full arp/nd
>> table.
>> The other option is the Netlink interface. I tried it and I got the
>> ARP/ND table :).
>> The third option is using /proc/net/arp, which only restricted to IP4.
>>
>> There is command line utilities that I excluding in my case.
>>
>> Is there another way to do it? what is the best way in my case?
>>
>> Thank you all.
>
> # strace arp -an
> [...]
> open("/proc/net/arp", O_RDONLY)         = 4
> fstat(4, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
> read(4, "IP address       HW type     Fla"..., 1024) = 310
> [...]
>
> # strace ip -6 neighbor show
> [...]
> socket(AF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, NETLINK_ROUTE) = 3
> setsockopt(3, SOL_SOCKET, SO_SNDBUF, [32768], 4) = 0
> setsockopt(3, SOL_SOCKET, SO_RCVBUF, [1048576], 4) = 0
> bind(3, {sa_family=AF_NETLINK, nl_pid=0, nl_groups=00000000}, 12) = 0
> getsockname(3, {sa_family=AF_NETLINK, nl_pid=30292, nl_groups=00000000},
> [12]) = 0
> sendto(3, {{len=40, type=RTM_GETLINK, flags=NLM_F_REQUEST|NLM_F_DUMP,
> seq=1503888680, pid=0},
> "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\10\0\35\0\1\0\0\0"}, 40, 0, NULL, 0) = 40
> recvmsg(3, {msg_name={sa_family=AF_NETLINK, nl_pid=0,
> nl_groups=00000000}, msg_namelen=12, msg_iov=[{iov_base=[{{len=1268,
> type=RTM_NEWLINK, flags=NLM_F_MULTI, seq=1503888680, pid=30292},
> "\0\0\4\3\1\0\0\0I\0\1\0\0\0\0\0\7\0\3\0lo\0\0\10\0\r\0\350\3\0\0"...},
> {{len=1280, type=RTM_NEWLINK, flags=NLM_F_MULTI, seq=1503888680,
> pid=30292},
> "\0\0\1\0\2\0\0\0C\20\1\0\0\0\0\0\t\0\3\0eno1\0\0\0\0\10\0\r\0"...}],
> iov_len=32768}], msg_iovlen=1, msg_controllen=0, msg_flags=0}, 0) = 2548
> [...]
>
> Seems like it's pretty obvious if you don't want to use the existing
> tools, just look at how the existing tools get this data.  IPv4 uses
> /proc/net/arp, IPv6 uses netlink.
>
> Cheers,
> -PJ
>
