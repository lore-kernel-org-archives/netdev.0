From: =?UTF-8?Q?S=C5=82awek_Janecki?= <janecki@gmail.com>
Subject: Re: TCP Delayed ACK in FIN/ACK
Date: Sat, 4 Aug 2012 21:20:45 +0200
Message-ID: <CACS4u_xFsLzCM6NVDY6abG9XRsxgtdyOndEChuSK8-g5XzU-aw@mail.gmail.com>
References: <CACS4u_zUF9T0rSsndhyVzgaauOBFJ4LTUeb432B1zg_oLHvTsg@mail.gmail.com>
 <CAFLxGvxqj+-rf5twsMPk-pRQqzqsK8-MSsKaez9cwarPmyEqzw@mail.gmail.com> <1344098083.9299.1503.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344098083.9299.1503.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have no such info in dmsg.
I think I will file a issue to Node.js Dev Team.
Thanks for reply.

On Sat, Aug 4, 2012 at 6:34 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Sat, 2012-08-04 at 16:51 +0200, richard -rw- weinberger wrote:
>> On Sat, Aug 4, 2012 at 4:45 PM, S=C5=82awek Janecki <janecki@gmail.c=
om> wrote:
>> > I have a node.js client (10.177.62.7) requesting some data from ht=
tp
>> > rest service from server (10.177.0.1).
>> > Client is simply using nodejs http.request() method (agent=3Dfalse=
).
>> > Client is on Ubuntu 11.10 box.
>> > Why client sends FIN ACK after 475ms? Why so slow? He should send =
=46IN
>> > ACK immediately.
>> > I have many situations like this. About 1% of whole traffic is req=
uest
>> > with delayed FIN ACK.
>> > Cpu idle on the client is about 99%, so nothing is draining CPU.
>> > How to debug this? What could it be? Is there any sysctl option I =
need to tune?
>> > I think this behaviour is the Delayed ACK feature of RFC1122 TCP s=
tack.
>> >
>> > Link to tcpdump picture (done on a client machine) :
>> > http://i48.tinypic.com/35cpogx.png
>> >
>> > Can you tell why kernel delayed that FIN/ACK.
>> > In tcpflow data there is exacly one ACK per packet comming from se=
rver.
>> > Why kernel delayed client FIN/ACK.
>> > It could avoid sending ACK every 'data' packet.
>> > But it choose to delay FIN/ACK?
>> > Is this possible? Is this a bug?
>> >
>> > I've also posted question on stackexchange:
>> > http://stackoverflow.com/questions/11711218/client-sends-delayed-f=
in-ack-500ms-to-server
>> >
>> > Please help.
>>
>> CC'ing netdev.
>>
>
> I see nothing wrong in this tcpdump. You should strace the applicatio=
n
> instead.
>
> FIN/ACK is sent when client closes its socket (or calls shutdown()), =
and
> not in reply of FIN sent by the server.
>
> Kernel has no additional delay. I suspect your client is slow process=
ing
> the server answer, then close() its socket _after_ data processing.
>
> Its possible tcp_send_fin() has to loop while allocating one skb unde=
r
> very high memory pressure, and it seems we have no counters for this
> case. But if it _was_ ever happening, you would have lot of messages =
in
> kernel log (dmesg) about alloc_skb_clone() failures.
>
>
>



--=20

pozdrawiam
S=C5=82awomir Janecki
