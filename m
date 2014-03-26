From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 11:27:06 -0400
Message-ID: <20140326152706.GC12372@tuxdriver.com>
References: <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com>
 <20140326111031.GB31370@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Thomas Graf <tgraf@suug.ch>,
	Jiri Pirko <jiri@resnulli.us>,
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
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40917 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389AbaCZPar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 11:30:47 -0400
Content-Disposition: inline
In-Reply-To: <20140326111031.GB31370@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 07:10:31AM -0400, Neil Horman wrote:
> On Tue, Mar 25, 2014 at 04:56:38PM -0400, Jamal Hadi Salim wrote:

> > I think i am with you mostly - just not on the visibility of a "master"
> > device.
> > Expose the ports. Users create bridges bonds and if the hardware is
> > capable it does the hard work to ensure consistency. No change in tools.
> > 
> But by creating net_devices that are registered in the current fashion we
> implicitly agree to levels of functionality that are assumed to be available and
> as such are not within the purview of a net_device to reject.  E.g. it is
> assumed that a netdevice can filter frames using iptables/ebtables, limit
> traffic using tc, etc. And if a switch fabric is short cutting traffic so that
> the cpu doesn't see them, those bits of functionality won't work.  I agree we
> can likely work around that with richer feature capabilities, but such an
> infrastructure would both require extensive kernel changes to fully cover the
> set of existing features at a sufficient granularity, and require user space
> changes to grok the feature set of a given device.  Not saying its impossibible
> or even undesireable mind you, just thats its not any less invasive than what
> I'm proposing.

Some of this sounds akin to the old (but true) arguments against TOE
hardware.  But as Thomas suggests, I think most of this disappears
if you give the driver the chance to implement such rules and/or fall
back to software-only forwarding.

While I'm sure there will be significant kernel changes to allow
for some of that, I think that by putting that intelligence in the
drivers we can avoid most/all of the user space changes for groking
device features.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
