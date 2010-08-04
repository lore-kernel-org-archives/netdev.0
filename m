From: Jack Zhang <jack.zhang2011@gmail.com>
Subject: Re: can TCP socket send buffer be over used?
Date: Wed, 4 Aug 2010 02:00:13 -0600
Message-ID: <AANLkTimhswtowB-TZ5Hj4KQXcf3gzjpxEJ8qO+PuWaPV@mail.gmail.com>
References: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
	<20100804032018.19fd9a36.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36003 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587Ab0HDIAe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 04:00:34 -0400
Received: by vws3 with SMTP id 3so3874351vws.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 01:00:33 -0700 (PDT)
In-Reply-To: <20100804032018.19fd9a36.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bill,

Thanks a lot for your help.

It does make sense!

As I'm writing this part into my master thesis, do you happen to know
which part in the source code I can maybe use as a proof in the thesis
that Linux uses 1/4 of the doubled buffer size for metadata?

Thanks,
Jack

On 4 August 2010 01:20, Bill Fink <billfink@mindspring.com> wrote:
> On Tue, 3 Aug 2010, Jack Zhang wrote:
>
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
>
> I'm not sure what's going on with this first case.
>
>> And When I set the send buffer size to 512 KB, i can get a throughpu=
t
>> up to 60 Mbps, which also seems to be impossible as the (buffer size=
)
>> / RTT is only 40 Mbps.
>
> But this case seems just about right. =A0Linux doubles the requested
> buffer size, then uses one quarter of that for overhead (not half),
> so you effectively get 50% more than requested (2X * 3/4 =3D 1.5X).
> Plugging your case into bc:
>
> wizin% bc
> scale=3D10
> 512*1024*8/0.100/10^6*3/2
> 62.9145600000
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0-Bill
>
>
>
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
>> but I was able to get way much more than the theoretical limit. So
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
