From: tgraf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Tue, 25 Mar 2014 21:39:58 +0000
Message-ID: <20140325213958.GE15723@casper.infradead.org>
References: <532AD5B3.6020205@mojatatu.com>
 <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <CAGVrzcacuU=RsnBOQh2-u+AjsMvznUYWFJru86w09+Vpdta2KQ@mail.gmail.com>
 <20140325194018.GG8102@hmsreliant.think-freely.org>
 <CAGVrzca3g8GMgoO8ptzmvCLusTJRzb9C0Duh+bXUrQPtB4LyaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy <andy@greyhouse.net>,
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
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42253 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbaCYVkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 17:40:00 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzca3g8GMgoO8ptzmvCLusTJRzb9C0Duh+bXUrQPtB4LyaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/14 at 01:00pm, Florian Fainelli wrote:
> 2014-03-25 12:40 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
> > On Tue, Mar 25, 2014 at 11:33:22AM -0700, Florian Fainelli wrote:
> >> 2014-03-25 10:39 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
> >> > 1) Ports on a switch chip are accessed using net_device structures, but
> >> > registered to a private list contained within the switch device, rather than to
> >> > the net namespaces device list.
> >>
> >> I think this would be a good model for simple embedded switches that
> >> only support 802.1q VLANs for instance, since we won't be able to get
> >> any actual data to be sent/received to any per-port netdevice, those
> >> per-port netdevices would only be effective for control at the L2
> >> level.
> >>
> >> For switches that do support tags, I think we do want per-port
> >> netdevices to appear in the regular netdevices namespace as those
> >> might be able to get actual data sent to/received from by using these
> >> tags, at least momentarily until a higher-level entity decides
> >> otherwise (e.g: by bridging, disabling interfaces...).
> >>
> > Well, perhaps thats the answer then  - Augment the model to allow for the
> > registration of net_devices to private lists within a switch device, but don't
> > require it.  If a given chip supports the assignment of L3 data by the cpu, the
> > use of iptables etc, let the switch driver do so, its not like we can't do that
> > already, but for the smaller devices, keeping them tightly controled via the
> > switch driver in such a way that user space can only access them with permission
> > from the switch driver.
> >
> > Does that seem reasonable?
> 
> Sure that looks good, the switch driver will know what L2/L3 features
> it has, and the higher levels will know how to utilize that
> information to construct the net_devices stacking and namespacing.


I think all it takes is to correctly apply the existing separation
which is already available but not applied right now.

We already have the L2/L3 separation in place:

net_device vs in_device/inet6_dev/....

A pure L2 device that will never do L3 on the CPU would only
need to set a flag which we check before allocating a in_device
and therefore prevent from all the L3 configs to be exposed.
