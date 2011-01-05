From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v2] net: Allow ethtool to set interface in loopback mode.
Date: Tue, 4 Jan 2011 17:39:23 -0800
Message-ID: <AANLkTim6VUBkT9NRX3jcufpXatNb9RLJbKZYCkVarFuX@mail.gmail.com>
References: <AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
	<1294187401-4662-1-git-send-email-maheshb@google.com>
	<20110104163645.0b3a3687@nehalam>
	<1294190504.2992.3.camel@localhost>
	<20110104172939.711b758d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Laurent Chavey <chavey@google.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:16661 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab1AEBj0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 20:39:26 -0500
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p051dOQ9015851
	for <netdev@vger.kernel.org>; Tue, 4 Jan 2011 17:39:24 -0800
Received: from bwz15 (bwz15.prod.google.com [10.188.26.15])
	by hpaq11.eem.corp.google.com with ESMTP id p051dNZC026560
	for <netdev@vger.kernel.org>; Tue, 4 Jan 2011 17:39:23 -0800
Received: by bwz15 with SMTP id 15so15112386bwz.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 17:39:23 -0800 (PST)
In-Reply-To: <20110104172939.711b758d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 4, 2011 at 5:29 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> On Wed, 05 Jan 2011 01:21:44 +0000
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>
>> On Tue, 2011-01-04 at 16:36 -0800, Stephen Hemminger wrote:
>> > On Tue, =A04 Jan 2011 16:30:01 -0800
>> > Mahesh Bandewar <maheshb@google.com> wrote:
>> >
>> > > This patch enables ethtool to set the loopback mode on a given i=
nterface.
>> > > By configuring the interface in loopback mode in conjunction wit=
h a policy
>> > > route / rule, a userland application can stress the egress / ing=
ress path
>> > > exposing the flows of the change in progress and potentially hel=
p developer(s)
>> > > understand the impact of those changes without even sending a pa=
cket out
>> > > on the network.
>> > >
>> > > Following set of commands illustrates one such example -
>> > > =A0 a) ip -4 addr add 192.168.1.1/24 dev eth1
>> > > =A0 b) ip -4 rule add from all iif eth1 lookup 250
>> > > =A0 c) ip -4 route add local 0/0 dev lo proto kernel scope host =
table 250
>> > > =A0 d) arp -Ds 192.168.1.100 eth1
>> > > =A0 e) arp -Ds 192.168.1.200 eth1
>> > > =A0 f) sysctl -w net.ipv4.ip_nonlocal_bind=3D1
>> > > =A0 g) sysctl -w net.ipv4.conf.all.accept_local=3D1
>> > > =A0 # Assuming that the machine has 8 cores
>> > > =A0 h) taskset 000f netserver -L 192.168.1.200
>> > > =A0 i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.1=
68.1.200 -l 30
>> > >
>> > > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> > > Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
>> >
>> > Since this is a boolean it SHOULD go into ethtool_flags rather tha=
n
>> > being a high level operation.
>>
>> It could do, but I though ETHTOOL_{G,S}FLAGS were intended for
>> controlling offload features.
>
> It just seems the number of hooks keeps growing which takes more spac=
e
> and increases complexity.
>
> There was some talk about changing GRO/TSO/UFO .. to be bits in FLAGS
> but not sure how far along that is.
> --
>

This is not merely getting / setting flags but involves invoking a
method from the driver(s). If done this way; the code in
ethtool_op_set_flags() will have to be special-cased to handle this
flag which (I think) would not be clean.
