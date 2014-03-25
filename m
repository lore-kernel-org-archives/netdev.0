From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Tue, 25 Mar 2014 16:56:38 -0400
Message-ID: <5331ED86.7020704@mojatatu.com>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us> <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Neil Horman <nhorman@tuxdriver.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:57594 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754122AbaCYU4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 16:56:44 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so1262308qaq.10
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 13:56:43 -0700 (PDT)
In-Reply-To: <20140325193533.GF8102@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/14 15:35, Neil Horman wrote:
> On Tue, Mar 25, 2014 at 06:00:09PM +0000, Thomas Graf wrote:

>> How about a new device flag indicating pure L2 mode? Any L3 address
>> configuration would fail with EAFNOSUPP.
>>
> Yeah, we've discussed that before, and it seems like a good idea, though I'm not
> sure that its flexible enough.  It clearly prevents L3 operations on devices
> that can only do L2, which is great, but that may not be sufficient for some
> devices.  For example, what if you wanted to use ebtables on an L2 port where
> the hardware can't mirror the actions of a given table rule?  Do we need to
> expand out those capabilities?

There are two capability approaches.
a) you do things and let the kernel reject
b) You discover the capabilities and do something more interesting.
We already do this kind of stuff in user tools today (simple example
is name->ifindex mapping querying).

What is missing is ability to store richer capabilities which are not
just boolean in nature.



>
> Maybe I'm not being clear. I'm not suggesting that we abandon the use of a
> net_device to do any of this work, only that we add a layer of indirection to
> get to it.  By Augmenting the existing network device stack to allow
> registration of net_devices to arbitrary lists, rather than to a fixes
> per-net-namespace global device list, we can operate net_devices that are only
> visible within the scope of a given switch fabric.  User space still works the
> same way, it just requires the specification of additional information when
> speaking to ports on a switch device that may not be directly accessible via the
> cpu.  For example, if a systems has a directly connected nic (em1), and a switch
> fabric with a master bridge port (sw1), and 10 external ports (sw1pX), we could
> access them all from user space via ip link show.  for example:
>
> 1) ip link show:
> em1
> sw1
>
> 2) ip link show sw1
> sw1
>
> 3) ip link show -p sw1
> sw1p0
> sw1p1
> sw1p2...
>
>
> The idea is to augment user space to allow the visibiliy of ports through the
> switch device, not directly, but using the same existing mechanisms.  We can
> reuse all the existing infrastruture, but with this model, control must pass
> through the switch device driver, allowing it to taylor available features by
> passing the netlink request on to the appropriate netdevice, or sending back an
> error itself.
>

I think i am with you mostly - just not on the visibility of a "master"
device.
Expose the ports. Users create bridges bonds and if the hardware is
capable it does the hard work to ensure consistency. No change in tools.

cheers,
jamal
