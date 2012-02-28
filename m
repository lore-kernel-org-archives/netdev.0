From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Tue, 28 Feb 2012 16:24:47 +0100
Message-ID: <4F4CF1BF.7080503@collabora.co.uk>
References: <1329753455-1106-1-git-send-email-javier@collabora.co.uk> <20120224.153616.117399887784547022.davem@davemloft.net> <4F4B8C66.5060206@collabora.co.uk> <20120227.140535.1623396420455657443.davem@davemloft.net> <1330426059.2139.21.camel@megeve> <20120228142846.GD187520@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	David Miller <davem@davemloft.net>, javier@collabora.co.uk,
	eric.dumazet@gmail.com, lennart@poettering.net,
	kay.sievers@vrfy.org, alban.crequy@collabora.co.uk,
	bart.cerneels@collabora.co.uk, sjoerd.simons@collabora.co.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120228142846.GD187520@jupiter.n2.diac24.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/28/2012 03:28 PM, David Lamparter wrote:
> On Tue, Feb 28, 2012 at 11:47:39AM +0100, Rodrigo Moya wrote:
>> > - slow readers: dropping packets vs blocking the sender. Although
>> >   datagrams are not reliable on IP, datagrams on Unix sockets are
>> never
>> >   lost. So if one receiver has its buffer full the sender is blocked
>> > instead of dropping packets. That way we guarantee a reliable
>> > communication channel.
> 
> This sounds like a terribly nice way to f*ck the entire D-Bus system by
> having one broken (or malicious) desktop application. What's the
> intended way of coping with users that block the socket by not reading?
> 
> 
> -David L.

The problem is that D-bus expects a reliable transport method (TCP or
SOCK_STREAM Unix socks) but this is not the case with multicast Unix
sockets. Since our implementation is for SOCK_SEQPACKET and SOCK_DGRAM
socket types.

So, you have to either add another layer to the D-bus protocol to make
it reliable (acks, retransmissions, flow control, etc) or avoid losing
D-bus messages (by blocking the sender if one of the receivers has its
buffer full).

Regards,
Javier
