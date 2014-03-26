From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 26 Mar 2014 08:58:29 -0400
Message-ID: <5332CEF5.1030202@mojatatu.com>
References: <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <5331ED86.7020704@mojatatu.com> <20140326111031.GB31370@hmsreliant.think-freely.org> <20140326112903.GG15723@casper.infradead.org>
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
To: Thomas Graf <tgraf@suug.ch>, Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:41733 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaCZM6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 08:58:33 -0400
Received: by mail-qc0-f170.google.com with SMTP id e9so2498867qcy.1
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 05:58:33 -0700 (PDT)
In-Reply-To: <20140326112903.GG15723@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/14 07:29, Thomas Graf wrote:
> On 03/26/14 at 07:10am, Neil Horman wrote:
>> But by creating net_devices that are registered in the current fashion we
>> implicitly agree to levels of functionality that are assumed to be available and
>> as such are not within the purview of a net_device to reject.  E.g. it is
>> assumed that a netdevice can filter frames using iptables/ebtables, limit
>> traffic using tc, etc.
>
> I think this is the point where we disagree. We already have several
> devices that hook into the rx handler and never have their packets
> pass through either iptables or ebtables. Better examples of this are
> macvtap or OVS.
>

I am going to disagree here.
Where it makes sense to use port handling is when you have port
layering.
Really dont need to create another parallel stack just because this
is to reflect what is in the hardware. There are corner cases, but
not the ones discussed.
Use ebtables if that is what the hardware reflects best.
Use tc when that is the better abstraction (example: for years now I
have modelled the broadcom acls with tc classifier/actions just fine).

> What should happen is that these devices are given a chance to implement
> the ACL in their own flow table. If no such facility exists, the rule
> insertion should fall back to software mode if that is possible (an
> OF capable switching chip could insert a 'upcall' flow), or as
> a last resort return an error to indicate EOPNOTSUPP.
>

I would like to specify where the acl rule goes.
Refer to the bridge port fdb offloading as an example.

cheers,
jamal
