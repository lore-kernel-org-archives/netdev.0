From: Ani Sinha <ani@arista.com>
Subject: Re: [PATCH 1/1] commit c6825c0976fa7893692e0e43b09740b419b23c09 upstream.
Date: Thu, 29 Oct 2015 17:01:24 -0700
Message-ID: <CAOxq_8M5J0RO8X4Rd70rCWcrbBOrX3_jn4-dmrT+Y3yPYGThTA@mail.gmail.com>
References: <alpine.OSX.2.20.1510261144390.3919@athabasca.local>
 <20151026200633.GA13476@salvia> <17709_1446014232_t9S6b5a3017652_20151028023650.7b76098f@playground>
 <20151029024052.28e11c83@playground>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Neal P. Murphy" <neal.p.murphy@alum.wpi.edu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20151029024052.28e11c83@playground>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2015 at 11:40 PM, Neal P. Murphy
<neal.p.murphy@alum.wpi.edu> wrote:
> On Wed, 28 Oct 2015 02:36:50 -0400
> "Neal P. Murphy" <neal.p.murphy@alum.wpi.edu> wrote:
>
>> On Mon, 26 Oct 2015 21:06:33 +0100
>> Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>>
>> > Hi,
>> >
>> > On Mon, Oct 26, 2015 at 11:55:39AM -0700, Ani Sinha wrote:
>> > > netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get
>> >
>> > Please, no need to Cc everyone here. Please, submit your Netfilter
>> > patches to netfilter-devel@vger.kernel.org.
>> >
>> > Moreover, it would be great if the subject includes something
>> > descriptive on what you need, for this I'd suggest:
>> >
>> > [PATCH -stable 3.4,backport] netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get
>> >
>> > I'm including Neal P. Murphy, he said he would help testing these
>> > backports, getting a Tested-by: tag usually speeds up things too.
>>
>
> I've probably done about as much seat-of-the-pants testing as I can. All opening/closing the same destination IP/port.
>
> Host: Debian Jessie, 8-core Vishera 8350 at 4.4 GHz, 16GiB RAM at (I think) 2100MHz.
>
> Traffic generator 1: 6-CPU KVM running 64-bit Smoothwall Express 3.1 (linux 3.4.109 without these patches), with 8GiB RAM and 9GiB swap. Packets sent across PURPLE (to bypass NAT and firewall).
>
> Traffic generator 2: 32-bit KVM running Smoothwall Express 3.1 (linux 3.4.110 with these patches), 3GiB RAM and minimal swap.
>
> In the first set of tests, generator 1's traffic passed through Generator 2 as a NATting firewall, to the host's web server. In the second set of tests, generator 2's traffic went through NAT to the host's web server.
>
> The load tests:
>   - 2500 processes using 2500 addresses and random src ports
>   - 2500 processes using 2500 addresses and the same src port
>   - 2500 processes using the same src address and port
>
> I also tested using stock NF timeouts and using 1 second timeouts.
>
> Bandwidth used got as high as 16Mb/s for some tests.
>
> Conntracks got up to 200 000 or so or bounced between 1 and 2, depending on the test and the timeouts.
>
> I did not reproduce the problem these patches solve. But more importantly, I saw no problems at all. Each time I terminated a test, RAM usage returned to about that of post-boot; so there were no apparent memory leaks. No kernel messages and no netfilter messages appeared during the tests.
>
> If I have time, I suppose I could run another set of tests: 2500 source processes using 2500 addresses times 200 ports to connect to 2500 addresses times 200 ports on a destination system. Each process opens 200 sockets, then closes them. And repeats ad infinitum. But I might have to be clever since I can't run 500 000 processes; but I could run 20 VMs; that would get it down to about 12 000 processes per VM. And I might have to figure out how to allow allow processes on the destination system to open hundreds or thousands of sockets.

Should I resend the patch with a Tested-by: tag?
