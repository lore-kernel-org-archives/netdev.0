From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Tue, 25 Mar 2014 14:42:08 -0700
Message-ID: <CAGVrzcZfUuFcr9j=_q1zr_jJE6ZaxxWCs5drsrsbH0hbCSkbcg@mail.gmail.com>
References: <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org>
 <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <20140325212632.GD15723@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
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
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:64888 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbaCYVmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 17:42:50 -0400
Received: by mail-lb0-f176.google.com with SMTP id 10so856038lbg.35
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 14:42:49 -0700 (PDT)
In-Reply-To: <20140325212632.GD15723@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-25 14:26 GMT-07:00 Thomas Graf <tgraf@suug.ch>:
> On 03/25/14 at 01:11pm, Florian Fainelli wrote:
>> 2014-03-25 12:35 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
>> > On Tue, Mar 25, 2014 at 06:00:09PM +0000, Thomas Graf wrote:
>> >> On top of that, like for VFs, we provide extended nested attributes or
>> >> alternate control paths such as via OVS that provide the additional
>> >> flexibility and control required by the more advanced devices.
>> > I'm sorry, I don't understand the relevance here.  Are you suggesting that to
>> > make this modification, we would need to augment more than a single set of
>> > netlink control paths?
>>
>> Not sure if I got this right, but there might be additional control
>> knobs required for specific Ethernet switch features that do not map
>> nicely, if at all with existing interfaces provided by ip/tc,
>> ethtool... although I guess one would say, well, then go add these
>> APIs instead of creating "extended" ones?
>
> Exactly. Some of the logic and configuration structure will not
> fit the existing model and is too switch specific to justify
> extending the generic link model. It also seems likely that some
> knobs will be switch specific. Not an issue as long as they are
> tunneled through the standard API and any effort is undertaken
> to generalize where it makes sense.

The question is how you would imagine conveying these switch-specific
features that do not (yet) map into a general feature, shall we go for
a separate netlink family, just like what Felix did in OpenWrt with
swconfig, without much stability from one kernel release to another,
as we migrate what was once a switch specific feature into a general
Ethernet switch feature?
-- 
Florian
