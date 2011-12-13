From: raviraj joshi <raviraj.j1991@gmail.com>
Subject: Re: kenel level packet capturing
Date: Tue, 13 Dec 2011 17:34:22 +0530
Message-ID: <CAKj1SsOra7u21u8Zq9rDLzv_Bhx8sPsah+SHByMYQbVc_j6LQA@mail.gmail.com>
References: <CAKj1SsP+GE=QqN8nx7aaAxXE8BODKb=vns_=SnbyySQjZp3-pg@mail.gmail.com>
	<CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com>
	<20111019123733.GA21324@synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20111019123733.GA21324@synalogic.ca>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
    We have to implement a kernel module for capturing of packets and
dumping onto disk as a part of our BE project.
We have decided to use PF_RING(a kernel module to capture packets) for
the same due to the number of advantages.

We have to now write a kernel module that will interact with pf_ring
module to get data and dump it onto disk.
To do this we figured out two approaches :

1. pf_ring has provided userland code to communicate with kernel
module which in turn used "socket" system calls and specified protocol
family as PF_RING(socket(PF_RING, SOCK_RAW, htons(ETH_P_ALL));) and
subsequently used other functions like setsockopt to get packets.
So one approach can be to use kernel counterparts of socket and
setsockopt and reuse the userland code in our kernel module(this will
save us from writing code to built some specific data structures and
handleing exceptional conditions).

2. second approach can be to identify functions which capture packets
in PF_RING kernel module and invoke them from our
kernel moduel.

Can anyone please comment on these approachs or tell us about other
options available, we have to essentially use services provided by
pf_ring module via a kernel module?

and what things should we follow to accomplish these approaches ?



PF_RING specific questions(if any one is aware of pf_ring please answer this):
We went through the userland code of pf_ring and got to know that
using pf_ring involves
1.setting up socket connection
2.binding the address
3.setting socket options
4.enabling socket ring
5.use packet_recv function to get packets
6.finally display packets and close the socket connection.
is this procedure which we figured out right?

we also found that the data we receive has two parts
1.pfring_pkthdr
2.sk_buff struct

is this correct?

we know this is not the right place to ask questions about pf_ring and
we are extremely sorry for this ,but we posted the
same questions on ntop mailing list and there was no response.

thanking,
Raviraj Joshi
PICT,Pune.

On Wed, Oct 19, 2011 at 6:07 PM, Benjamin Poirier
<benjamin.poirier@gmail.com> wrote:
> On 11/10/19 12:24, raviraj joshi wrote:
>> Hi,
>>
>> We are making a kernel level packet capture module as a part of our BE project .
>> We are finding it difficult to understand kenel networking code.
>> We studied structures and functions like sk_buff, netif_rx(),dev_alloc_skb.
>>
>> However we were not able to trace the actual path a simple packet follows.
>
> You might find
> http://vger.kernel.org/netconf2011_slides/jesse_brandeburg_netconf2011.pdf
> interesting. It contains call chains of UDP processing at all levels in
> the stack (driver, below ip stack, above ip stack) for tx and rx.
>
> -Ben
