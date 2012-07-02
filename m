From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: Re: AF_BUS socket address family
Date: Mon, 02 Jul 2012 17:18:45 +0200
Message-ID: <4FF1BBD5.8080804@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Chris Friesen <chris.friesen@genband.com>,
	David Miller <davem@davemloft.net>,
	vincent.sanders@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Mon, Jul 2, 2012 at 6:49 AM, Chris Friesen <chris.friesen@genband.com> wrote:
> On 06/29/2012 05:18 PM, David Miller wrote:
>>
>> From: Vincent Sanders<vincent.sanders@collabora.co.uk>
>> Date: Sat, 30 Jun 2012 00:12:37 +0100
>>
>>> I had hoped you would have at least read the opening list where I
>>> outlined the underlying features which explain why none of the
>>> existing IPC match the requirements.
>>
>> I had hoped that you had read the part we told you last time where
>> we explained why multicast and "reliable delivery" are fundamentally
>> incompatible attributes.
>>
>> We are not creating a full address family in the kernel which exists
>> for one, and only one, specific and difficult user.
>
>
> For what it's worth, the company I work for (and a number of other
> companies) currently use an out-of-tree datagram multicast messaging
> protocol family based on AF_UNIX.
>
> If AF_BUS were to be accepted, it would be essentially trivial for us to
> port our existing userspace messaging library to use it instead of our
> current protocol family, and we would almost certainly do so.
>
> I'd love to see AF_BUS go in.
>
> Chris Friesen
>

Hi Chris,

Thanks a lot for your comments and feedback.

We tried different approaches before developing the AF_BUS socket family and one
of them was extending AF_UNIX to support multicast. We posted our patches [1]
and the feedback was that the AF_UNIX code was already a complex and difficult
code to maintain. So, we decided to implement a new family (AF_BUS) that is
orthogonal to the rest of the networking stack and no added complexity nor
performance penalty would pay a user not using our IPC solution.

Looking at netdev archives I saw that you both raised the question about
multicast on unix sockets and post an implementation on early 2003. So if I
understand correctly you are maintaining an out-of-tree solution for around 9
years now.

We developed AF_BUS to improve the performance of the D-Bus IPC system (and our
results show us a 2X speedup) but design it to be as generic as possible so
other users can take advantage of it.

It would be a great help if you can join the discussion and explain the
arguments of your company (and the others companies you were talking about) in
favor of a simpler multicast socket family.

The fact that your company spent lots of engineering resources to maintain an
out-of-tree patch-set for 9 years should raise some eyebrows and convince more
than one people that a simpler local multicast solution is needed on the Linux
kernel (which was one of the reasons why Google also developed Binder I guess).

[1]: https://lkml.org/lkml/2012/2/20/84
[2]: https://lkml.org/lkml/2003/2/27/150
[3]: http://lwn.net/Articles/27001/

Thanks a lot and best regards,

Javier
