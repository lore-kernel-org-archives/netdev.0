From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Thu, 9 Feb 2017 07:17:09 -0800
Message-ID: <CANn89iJte06Ud6O2bKkgP8HZxx485dYwVY1uvZrAFCn5JA6L0w@mail.gmail.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
 <20170209151220.GA4843@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        Philip Pettersson <philip.pettersson@gmail.com>,
        weongyo.linux@gmail.com, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170209151220.GA4843@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 9, 2017 at 7:12 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (02/09/17 14:14), Dmitry Vyukov wrote:
>>
>> Call Trace:
>    :
>>  packet_rcv_has_room+0x25/0xb0 net/packet/af_packet.c:1308
>>  fanout_demux_rollover+0x3bb/0x6b0 net/packet/af_packet.c:1388
>>  packet_rcv_fanout+0x674/0x800 net/packet/af_packet.c:1490
>>  dev_queue_xmit_nit+0x73a/0xa90 net/core/dev.c:1898
>     :
>>  tcp_sendmsg_fastopen net/ipv4/tcp.c:1110 [inline]
>     :
>
> looks like a race between a NIT socket (tcpdump, maybe?) that is closing,
> and a standard tcp socket.. packet_release() takes the po->bind_lock
> to remove the socket from the ptype_all NIT queue. but how does
> that sync with the Tx path for other af_inet/af_inet6 sockets?

RCU protection for hooks.
