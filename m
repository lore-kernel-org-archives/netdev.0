From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Tue, 25 Mar 2014 17:22:27 -0400
Message-ID: <5331F393.5020508@mojatatu.com>
References: <532AD5B3.6020205@mojatatu.com> <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <20140325203110.GH8102@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
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
To: Neil Horman <nhorman@tuxdriver.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:59935 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaCYVWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 17:22:32 -0400
Received: by mail-qa0-f44.google.com with SMTP id f11so1270523qae.17
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 14:22:31 -0700 (PDT)
In-Reply-To: <20140325203110.GH8102@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/14 16:31, Neil Horman wrote:
> On Tue, Mar 25, 2014 at 01:11:55PM -0700, Florian Fainelli wrote:
>> 2014-03-25 12:35 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
>>> On Tue, Mar 25, 2014 at 06:00:09PM +0000, Thomas Graf wrote:

>> Not sure if I got this right, but there might be additional control
>> knobs required for specific Ethernet switch features that do not map
>> nicely, if at all with existing interfaces provided by ip/tc,
>> ethtool... although I guess one would say, well, then go add these
>> APIs instead of creating "extended" ones?
> Ostensibly yes, but I'm not well versed enough in what those interfaces are, to
> know for certain.  I definately agree however, that if a given interface outside
> the scope of network device control is required (say for example, direct access
> to a switch fabrics cam lookup table), then you are correct, we should develop
> those api's rather than shoehorn them into a net_device model
>

Sorry i should have started from last and gone backwards reading emails.
So things like stats that are only available via some chip but not
others come to mind. But we know how to carry those things to user
space via netlink. Give me an IFLA_KIND and i can give you access to
set/get extended features.
I dont see much disagreement to the end goals from any of the goals.
Thou shalt make current tools work.
The challenge perhaps maybe the different implementation approaches.
It seems we are also agreeing that there will be some conduit driver
which will expose ports to the kernel. It will likely own the ASIC
feature set and can be queried for capabilities indirectly.
It can talk DSA, PCI etc.

For when things dont fit: I would expect this "driver" to
also be the conduit to the chip resources and any
translation that needs to happen between the kernel view of the
abstraction to the chip view.

cheers,
jamal
