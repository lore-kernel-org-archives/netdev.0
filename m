From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v3 net-next 0/4] net: low latency Ethernet device polling
Date: Tue, 21 May 2013 15:29:24 +0300
Message-ID: <519B68A4.3010406@linux.intel.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com> <519B632F.7040202@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Alex Rosenbaum <alexr@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519B632F.7040202@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many of the questions you asked are covered in our RFC cover letter, bu=
t=20
I will touch them briefly

On 21/05/2013 15:06, Alex Rosenbaum wrote:
> 1. It seem this patch does not cover epoll/select and such IO muxing =
APIs?

We are thinking about how to implement epoll support as one of the next=
=20
steps.

What benchmarks are you using to test poll/select/epoll?


> 2. How is the logic aware of RSS and RFS?
>
> With TCP sockets, the driver knows the specific ring it need to poll =
so
> this should be mapped and provide the best latency.

This code is blissfully oblivious of RFS and RSS, it only assumes that=20
the packets for a socket are likely to continue to come on the same que=
ue.
The code is designed to be correct even if you get your data on the=20
wrong queue. (your performance will suffer but no more than that.)


> 3. I could not find any reference to multi-thread on single core logi=
c.
> This can causes the opposite effect and create contentions and higher
> latency=E2=80=99s.

Again, the only bad thing that will happen if you misconfigure this is =
a=20
performance hit, we will not deadlock.

-Eliezer
