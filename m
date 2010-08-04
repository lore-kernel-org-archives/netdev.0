From: Jack Zhang <jack.zhang2011@gmail.com>
Subject: Re: can TCP send buffer be over used?
Date: Tue, 3 Aug 2010 20:38:07 -0600
Message-ID: <AANLkTikWH8NQZ5CYN7ytPYg-tK=eXF=OgJn=cuAoVexO@mail.gmail.com>
References: <AANLkTik84JAwmcRQ_HPrCN5DxWWaufNCdC5e6Cgyu5kQ@mail.gmail.com>
	<58.68.27492.02BB85C4@cdptpa-omtalb.mail.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Leslie Rhorer <lrhorer@satx.rr.com>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <58.68.27492.02BB85C4@cdptpa-omtalb.mail.rr.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Leslie,

Thanks for your reply!

> 1. =A0Your hosts support window scaling.

Yes, my transmit and receive hosts both support window scaling.

The receive end is using TCP autotuning, with the maximum buffer size
set to 16 MB, which is quite enough for my 100 Mbps link with 100 ms
RTT, as this link only requires 1.25 MB send buffer size to fill the
pipe.

The send host also supports window scaling. The size of the send
buffer, however, is set by setsockopt(), which should cancel the TCP
autotuning on this buffer. Therefore I don't think the TCP autotuning
is working for the send buffer.

> 2. =A0Your emulation is faulty. =A0There is no way to "optimize" the =
situation.
> For any transport protocol (TCP or otherwise) that guarantees accurat=
e
> delivery of a payload, the transmitter cannot be allowed to send more=
 data
> without acknowledgement of receipt of all the sent data than the rece=
iver
> can assemble in one chunk. =A0This puts an absolute (although configu=
rable)
> limit on the throughput of the data based upon the lag time between w=
hen the
> first byte of the window is sent and when the transmitting host recei=
ves an
> acknowledgement of the packet arriving safely.

This could be the case. I'll look more closely to see if I can find
anything about the accuracy of the emulated link delay.

There is one part of your suggestion I'm not sure if I fully
understand though...  "the transmitter cannot be allowed to send more
data without acknowledgement of receipt of all the sent data than the
receiver can assemble in one chunk. " I take it as the transmitter
cannot send data of more than the receive window size without ack of
the sent data. Is that what you meant?

> 3. =A0Your measurement is based upon transfers that are too small in =
extent.

I was transferring 1 GB data over the 100 Mbps link. Do you think if I
should increase the size of the transfer?

Thanks a lot!

Jack


On 3 August 2010 18:58, Leslie Rhorer <lrhorer@satx.rr.com> wrote:
>> -----Original Message-----
>> From: linux-net-owner@vger.kernel.org [mailto:linux-net-
>> owner@vger.kernel.org] On Behalf Of Jack Zhang
>> Sent: Tuesday, August 03, 2010 7:13 PM
>> To: linux-net@vger.kernel.org
>> Subject: can TCP send buffer be over used?
>>
>> Hi there,
>>
>> I'm doing experiments with (modified*) software iSCSI over a link wi=
th
>> an emulated Round-Trip Time (RTT) of 100 ms by netem.
>>
>> For example, when I set the send buffer size to 128 KB, i could get =
a
>> throughput up to 43 Mbps, which seems to be impossible as the (buffe=
r
>> size) / RTT is only 10 Mbps.
>> And When I set the send buffer size to 512 KB, i can get a throughpu=
t
>> up to 60 Mbps, which also seems to be impossible as the (buffer size=
)
>> / RTT is only 40 Mbps.
>>
>> I understand that when the buffer size is set to 128 KB, I actually
>> got a buffer of 256 KB as the kernel doubles the buffer size. I also
>> understand that half the doubled buffer size is used for meta data
>> instead of the actual data to be transferred. So basically the
>> effective buffer sizes for the two examples =A0are just 128 KB and 5=
12
>> KB respectively.
>>
>> So I was confused because, theoretically, send buffers of 128 KB and
>> 512 KB should achieve no more than 10 Mbps and 40 Mbps respectively
>> but I was able to achieve way much more than the theoretical limit. =
So
>> I was wondering is there any chance the send buffer can be "overused=
"?
>> or there is some other mechanism inside TCP is doing some
>> optimization?
>>
>> * the modification is to disable "TCP_NODELAY" , enable
>> "use_clustering" for SCSI, and set different send buffer sizes for t=
he
>> TCP socket buffer.
>>
>> Any idea will be highly appreciated.
>>
>> Thanks a lot!
>
> =A0 =A0 =A0 =A0I see two possibiities:
>
> 1. =A0Your hosts support window scaling.
>
> 2. =A0Your emulation is faulty. =A0There is no way to "optimize" the =
situation.
> For any transport protocol (TCP or otherwise) that guarantees accurat=
e
> delivery of a payload, the transmitter cannot be allowed to send more=
 data
> without acknowledgement of receipt of all the sent data than the rece=
iver
> can assemble in one chunk. =A0This puts an absolute (although configu=
rable)
> limit on the throughput of the data based upon the lag time between w=
hen the
> first byte of the window is sent and when the transmitting host recei=
ves an
> acknowledgement of the packet arriving safely.
>
> 3. =A0Your measurement is based upon transfers that are too small in =
extent.
>
>
