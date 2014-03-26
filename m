From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 16:21:57 -0700
Message-ID: <CAGVrzcavFLyQC6A_6hqGa-iqXkkTyZK2V7Zq9UiOix1Y0xEK2w@mail.gmail.com>
References: <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com> <20140326111031.GB31370@hmsreliant.think-freely.org>
 <20140326112903.GG15723@casper.infradead.org> <20140326182122.GC31370@hmsreliant.think-freely.org>
 <CAGVrzcYNW0Z96mL-MecY=mte=+TcFn8k3eSY4pqi9h0N2jF7hw@mail.gmail.com>
 <53335838.3060409@mojatatu.com> <20140326231533.GA11773@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:54600 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755750AbaCZXWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 19:22:39 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2518413pdj.36
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 16:22:38 -0700 (PDT)
In-Reply-To: <20140326231533.GA11773@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-26 16:15 GMT-07:00 Thomas Graf <tgraf@suug.ch>:
> On 03/26/14 at 06:44pm, Jamal Hadi Salim wrote:
>> OTOH, the owrt view is probably because (If i understood correctly
>> last time), there are cases where there is no way to even pass packets
>> and attribute them to the originating switch ports. Infact, in some
>> cases  there may be no way at all to even pass packets to the kernel.
>> Did i  understand that part correctly?
>> I suppose this is eventually all part of that capability discovery.
>
> Listening to Florian it sounds like the fact that a separate control
> path was chosen early on in owrt got rid of the main driver to abstract
> everything through globally visible net_devices. Reusing existing
> tools was never an objective.

Correct. OpenWrt already has a fairly custom user-space, so it was
deemed reasonable to have another lightweight, yet custom control
interfaces for switches. The ability to use an unmodified Ethernet
driver was also a key goal. The reasons for putting that in the kernel
versus using e.g: an ioctl(SIOCGMIIREG) based approach in user-space,
is that it allows for better abstraction between control paths (MDIO,
I2C, SPI, memory-mapped I/O ...), and preserves the "kernel has
hardware ownership" paradigm.

>
> I believe that the question whether a particular port will send
> packets to the cpu does not matter that much. We'll see both and we'll
> see various forms of hybrid models with software based learnings paths,
> slow paths, and deliberate upcalls.
>
> The simpler the model, the better. If the desire to hide some of the
> complexity is driven by usability when I believe that hiding should
> happen in user space.
-- 
Florian
