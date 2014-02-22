From: jerry <jerry.lilijun@huawei.com>
Subject: Re: netmap, VALE and netmap pipes
Date: Sat, 22 Feb 2014 09:03:17 +0800
Message-ID: <5307F755.4090303@huawei.com>
References: <CA+hQ2+gbs9aBneUaDGAnKVoPHspzc=5o+h+f_K=T+Cy8sRxr+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Luigi Rizzo <rizzo@iet.unipi.it>, <netdev@vger.kernel.org>,
	"freebsd-net@freebsd.org" <net@freebsd.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:27206 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbaBVBD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 20:03:27 -0500
In-Reply-To: <CA+hQ2+gbs9aBneUaDGAnKVoPHspzc=5o+h+f_K=T+Cy8sRxr+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Luigi,

How to use netmap pipe by pkt-gen commands?
I have tried the commands as follows:
  ./pkt-gen -i netmap:pipename{1 -f tx
  ./pkt-gen -i netmap:pipename}1 -f rx  (in another terminal)
But it works failed.
Should the pipename be replaced with a invalid NIC name such as "eth3" in netmap mode?

The netmap pipe works from software ring to software ring independently with NICs, I understand. Is that right?

B.R.
Jerry

On 2014/2/17 18:11, Luigi Rizzo wrote:
> Hi,
> we have recently made a few extensions to netmap/VALE and put various
> pieces of code on public repositories, so i thought i'd share the
> pointers. All the code below runs with equal features and performance
> on FreeBSD and Linux, and we are trying to upstream it in the relevant
> projects if possible (as an example, QEMU recently added a netmap backend),
> at which point some of these clone repositories will become unnecessary.
> 
> See http://info.iet.unipi.it/~luigi/netmap for more details.
> 
> https://code.google.com/p/netmap/
>     The latest netmap code for FreeBSD/Linux. It has native support
>     for certain NICs; emulated netmap over unmodified drivers;
>     enhanced parallelism in the VALE switch (20 Mpps/source, scaling
>     up to ~50Mpps); and a new feature called "netmap pipe" that
>     does zero-copy blocking I/O at over 100 Mpps.
>         Other features are the ability to allocate tons of extra
>     netmap buffers, and configurable sharing of memory among NICs,
>     VALE ports and netmap pipes. This increases the opportunity for
>     zero copy operation.
