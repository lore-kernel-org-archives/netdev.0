From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 0/6] net: Add STT support.
Date: Mon, 2 Feb 2015 10:44:33 -0800
Message-ID: <CALnjE+qGjvTo0MdiNpS9v_ZjGJfLChV34ymojqYEz5A+UstXaA@mail.gmail.com>
References: <1422574156-1831-1-git-send-email-pshelar@nicira.com>
	<54CAFE89.4090509@gmail.com>
	<CALnjE+pPh5nSvaLTnM-a0r2Gm6K8Hz5BU_CsiWzYmwijPCOgHg@mail.gmail.com>
	<CA+mtBx_fFBY_FAsnAo8yu5bjoq5BqPY3Es_19oBdeqrjp4RdiA@mail.gmail.com>
	<CALnjE+rjoRXnKsT9z2CK0BuYrxwqk+0FZq1=QwoPiysPN0gxZw@mail.gmail.com>
	<20150130184446.GF13164@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:39502 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753015AbbBBSoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 13:44:37 -0500
Received: by mail-ig0-f182.google.com with SMTP id h15so3875184igd.3
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 10:44:36 -0800 (PST)
In-Reply-To: <20150130184446.GF13164@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2015 at 10:44 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Thu, Jan 29, 2015 at 09:03:14PM -0800, Pravin Shelar wrote:
>> On Thu, Jan 29, 2015 at 8:17 PM, Tom Herbert <therbert@google.com> wrote:
>> > On Thu, Jan 29, 2015 at 8:04 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>> >> On Thu, Jan 29, 2015 at 7:46 PM, Alexander Duyck
>> >> <alexander.duyck@gmail.com> wrote:
>> >>> On 01/29/2015 03:29 PM, Pravin B Shelar wrote:
>> >>>> Following patch series adds support for Stateless Transport
>> >>>> Tunneling protocol.
>> >>>> STT uses TCP segmentation offload available in most of NIC. On
>> >>>> packet xmit STT driver appends STT header along with TCP header
>> >>>> to the packet. For GSO packet GSO parameters are set according
>> >>>> to tunnel configuration and packet is handed over to networking
>> >>>> stack. This allows use of segmentation offload available in NICs
>> >>>>
>> >>>> The protocol is documented at
>> >>>> http://www.ietf.org/archive/id/draft-davie-stt-06.txt
>> >>>>
>> >>>> I will send out OVS userspace patch on ovs-dev mailing list.
>> >>>>
>> >>>> Following are test results. All tests are done on net-next with
>> >>>> STT and VXLAN kernel device without OVS.
>> >>>>
>> >>>> Single Netperf session:
>> >>>> =======================
>> >>>> VXLAN:
>> >>>>     CPU utilization
>> >>>>      - Send local: 1.26
>> >>>>      - Recv remote: 8.62
>> >>>>     Throughput: 4.9 Gbit/sec
>> >>>> STT:
>> >>>>     CPU utilization
>> >>>>      - Send local: 1.01
>> >>>>      - Recv remote: 1.8
>> >>>>     Throughput: 9.45 Gbit/sec
>> >>>>
>> >>>> Five Netperf sessions:
>> >>>> ======================
>> >>>> VXLAN:
>> >>>>     CPU utilization
>> >>>>      - Send local: 9.7
>> >>>>      - Recv remote: 70 (varies from 60 to 80)
>> >>>>     Throughput: 9.05 Gbit/sec
>> >>>> STT:
>> >>>>     CPU utilization
>> >>>>      - Send local: 5.85
>> >>>>      - Recv remote: 14
>> >>>>     Throughput: 9.47 Gbit/sec
>> >>>>
>> >>>
>> >>> What does the small packet or non-TCP performance look like for STT vs
>> >>> VXLAN?  My concern is that STT looks like it is a one trick pony since
>> >>> all your numbers show is TCP TSO performance, and based on some of the
>> >>> comments in your patches it seems like other protocols such as UDP are
>> >>> going to suffer pretty badly due to things like the linearization overhead.
>> >>>
>> >>
>> >> Current implementation is targeted for TCP workloads thats why I
>> >> posted numbers with TCP, once UDP is optimized we can discuss UDP
>> >> numbers. I am pretty sure the STT code can be optimized further
>> >> specially for protocols other than TCP.
>> >> --
>> > There are many TCP workloads that use small packets, it is critical to
>> > test for these also. E.g. "super_netperf 200 -H <addr> -l 120 -t
>> > TCP_RR -- -r 1,1"
>> >
>> I have not tried it on STT device, I will collect those numbers.
>>
>> > Please provide the *exact* commands that you are using to configure
>> > stt for optimal performance.
>> >
>> To create STT tunnel device.
>> `ip link add stt1  type stt key 1 remote 1.1.2.128`
>>
>> No other configuration is needed.
>
> Thanks for posting some performance numbers with your patch.  I also
> don't want to 'pile on' with additional complaints, but I do have one
> request.
>
> Can you share any specs (including number of cores and NIC hardware
> used) for the systems that gave you the above results?   If you do not
> want to endorse a particular NIC that is fine --  I'm mostly curious how
> many cores were used and if UDP and TCP RSS were both being used in this
> configuration.
>

I used 16 core (Sandy bridge) machine with intel 10G NIC. I enabled
both UDP and TCP RSS for all tests.
