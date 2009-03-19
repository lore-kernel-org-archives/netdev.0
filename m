From: Ryousei Takano <ryousei@gmail.com>
Subject: Re: [lxc-devel] Poor bridging performance on 10 GbE
Date: Thu, 19 Mar 2009 14:37:58 +0900
Message-ID: <b30d1c3b0903182237w7667c5bbt1ea098025f3b5f36@mail.gmail.com>
References: <b30d1c3b0903180221h5175618eue162ffdec3817b4c@mail.gmail.com>
	 <49C0C87B.7070507@fr.ibm.com>
	 <b30d1c3b0903180856r6dce554ap35b8d6a3ee7829e0@mail.gmail.com>
	 <m1wsamcp4n.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	lxc-devel@lists.sourceforge.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:47428 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914AbZCSFiB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:38:01 -0400
Received: by rv-out-0506.google.com with SMTP id f9so393208rvb.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:37:58 -0700 (PDT)
In-Reply-To: <m1wsamcp4n.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Mar 19, 2009 at 9:50 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:

[snip]

> Bridging last I looked uses the least common denominator of hardware
> offloads. =A0Which likely explains why adding a veth decreased your
> bridging performance.
>
At least now LRO cannot coexist bridging.
So I disable the LRO feature of the myri10ge driver.

>>>> Here is my experimental setting:
>>>> =A0 =A0 =A0 =A0OS: Ubuntu server 8.10 amd64
>>>> =A0 =A0 =A0 =A0Kernel: 2.6.27-rc8 (checkout from the lxc git repos=
itory)
>>>
>>> I would recommend to use the 2.6.29-rc8 vanilla because this kernel=
 does no
>>> longer need patches, a lot of fixes were done in the network namesp=
ace and
>>> maybe the bridge has been improved in the meantime :)
>>>
>> I checked out the 2.6.29-rc8 vanilla kernel.
>> The performance after issuing lxc-start improved to 8.7 Gbps!
>> It's a big improvement, while some performance loss remains.
>> Can not we avoid this loss?
>
> Good question. =A0Any chance you can profile this and see where the
> performance loss seems to be coming from?
>
I found out this issue is caused by decreasing the MTU size.
Myri-10G's MTU size is 9000 bytes; the veth' MTU size is 1500 bytes.
After bridging veth, MTU size decreases from 9000 to 1500 bytes.
I changed the veth's MTU size to 9000 bytes, and then I confirmed
the throughput improved to 9.6 Gbps.

The throughput between LXC containers also improved to 4.9 Gbps
by changing the MTU sizes.

So I propose to add lxc.network.mtu into the LXC configuration.
How does that sound?

> Eric
>

Best regards,
Ryousei Takano
