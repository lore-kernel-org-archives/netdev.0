From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Tue, 23 Sep 2014 10:52:05 +0100
Message-ID: <20140923095205.GC6944@casper.infradead.org>
References: <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com>
 <541CAA3C.5080105@intel.com>
 <20140920081426.GE1821@nanopsycho.orion>
 <20140920105354.GA29419@casper.infradead.org>
 <CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
 <20140922081341.GA20905@casper.infradead.org>
 <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
 <CAADnVQKhUAR=qVg9q82ngYMzQnoDVbq+wupzdMrH8WiCeMiU4A@mail.gmail.com>
 <CA+mtBx-mJE6SW2bqf3_t6iu=o5FY1WAF1ByeZpDJnc+6fpK6nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59829 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbaIWJwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 05:52:10 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx-mJE6SW2bqf3_t6iu=o5FY1WAF1ByeZpDJnc+6fpK6nA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/14 at 07:16pm, Tom Herbert wrote:
> Turn on UDP RSS on the device and I bet you'll see those differences
> go away! Once we moved to UDP encapsulation, there's really little
> value in looking at inner headers for RSS or ECMP, this should be
> sufficient. Sure someone might want to parse the inner headers for
> some sort of advanced RX steering, but again this implies rx-filtering
> and not switch functionality.

Agreed. The reason we discuss this in the context of this thread is
because the required rx-filtering capabilities seem to be introduced
in the form of (adapted) switch chip integrations onto NICs. In that
sense, OVS is essentially doing advanced RX steering in software.

I agree that switch functionality (whatever that specifically implies)
is not strictly required for the host if you consider queue
redirection as part of RX steering. The exception here would be use
of SR-IOV which could be highly interesting for corner cases if
combined with smart elephant guest detection. A classic example would
be NFV deployed in a virtualized environment, i.e. a virtual firewall
or DPI application serving a bunch of guests.

> If this is something that doesn't require any model change to the
> stack and is just a clever backend for rx-filters or tc, then I'm fine
> with that!

I haven't seen any model change proposed. I'm most certainly not
advocating that. Anyone who can live a model change might as well
just stick to SnabbSwitch or DPDK.
