From: Jesse Gross <jesse@nicira.com>
Subject: Re: Flow Control and Port Mirroring Revisited
Date: Thu, 13 Jan 2011 10:45:38 -0500
Message-ID: <AANLkTimO=5HmTJO1kmHGAWa-HTac+3d0TbrmJX5W4hVu@mail.gmail.com>
References: <20110106093312.GA1564@verge.net.au>
	<1294309362.3074.11.camel@edumazet-laptop>
	<20110106124439.GA17004@verge.net.au>
	<AANLkTinJK-nbkP5_ee2cuS8RA7jTB4-bcWmAf4bjSouP@mail.gmail.com>
	<20110107012356.GA1257@verge.net.au>
	<20110110093155.GB13420@verge.net.au>
	<20110113064718.GA17905@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, dev@openvswitch.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110113064718.GA17905@verge.net.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2011 at 1:47 AM, Simon Horman <horms@verge.net.au> wrot=
e:
> On Mon, Jan 10, 2011 at 06:31:55PM +0900, Simon Horman wrote:
>> On Fri, Jan 07, 2011 at 10:23:58AM +0900, Simon Horman wrote:
>> > On Thu, Jan 06, 2011 at 05:38:01PM -0500, Jesse Gross wrote:
>> >
>> > [ snip ]
>> > >
>> > > I know that everyone likes a nice netperf result but I agree wit=
h
>> > > Michael that this probably isn't the right question to be asking=
=2E =A0I
>> > > don't think that socket buffers are a real solution to the flow
>> > > control problem: they happen to provide that functionality but i=
t's
>> > > more of a side effect than anything. =A0It's just that the amoun=
t of
>> > > memory consumed by packets in the queue(s) doesn't really have a=
ny
>> > > implicit meaning for flow control (think multiple physical adapt=
ers,
>> > > all with the same speed instead of a virtual device and a physic=
al
>> > > device with wildly different speeds). =A0The analog in the physi=
cal
>> > > world that you're looking for would be Ethernet flow control.
>> > > Obviously, if the question is limiting CPU or memory consumption=
 then
>> > > that's a different story.
>> >
>> > Point taken. I will see if I can control CPU (and thus memory) con=
sumption
>> > using cgroups and/or tc.
>>
>> I have found that I can successfully control the throughput using
>> the following techniques
>>
>> 1) Place a tc egress filter on dummy0
>>
>> 2) Use ovs-ofctl to add a flow that sends skbs to dummy0 and then et=
h1,
>> =A0 =A0this is effectively the same as one of my hacks to the datapa=
th
>> =A0 =A0that I mentioned in an earlier mail. The result is that eth1
>> =A0 =A0"paces" the connection.
>
> Further to this, I wonder if there is any interest in providing
> a method to switch the action order - using ovs-ofctl is a hack imho =
-
> and/or switching the default action order for mirroring.

I'm not sure that there is a way to do this that is correct in the
generic case.  It's possible that the destination could be a VM while
packets are being mirrored to a physical device or we could be
multicasting or some other arbitrarily complex scenario.  Just think
of what a physical switch would do if it has ports with two different
speeds.
