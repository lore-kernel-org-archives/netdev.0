From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Tue, 23 Sep 2014 00:11:30 -0400
Message-ID: <20140923041130.GA10808@gospo.home.greyhouse.net>
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
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
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
	Roopa Prabh
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:46526 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbaIWEKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 00:10:32 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx-mJE6SW2bqf3_t6iu=o5FY1WAF1ByeZpDJnc+6fpK6nA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2014 at 07:16:47PM -0700, Tom Herbert wrote:
[...]
> 
> Alexei, I believe you said previously said that SW should not dictate
> HW models. I agree with this, but also believe the converse is true--
> HW shouldn't dictate SW model. This is really why I'm raising the
> question of what it means to integrate a switch into the host stack.

Tom, when I read this I cannot help but remind myself that the
intentions/hopes/dreams of those on this thread and how different their
views can be on what it means to add additional 'offload support' to the
kernel.

There are clearly some that are most interested in how an eSwitch on an
SR-IOV capable NIC be controlled can provide traditional forwarding help
as well as offload the various technologies they hope to terminate
at/inside their endpoint (host/guest/container) -- Thomas's _simple_
use-case demonstrates this. ;)  This is a logical extention/increase in
functionality that is offered in many eSwitches that was previously
hidden from the user with the first generation SR-IOV capable network
devices on hosts/servers.

Others (like Florian who has been working to extend DSA or those pushing
hardware vendors to make SDKs more open) where the existing bridging/
routing/offload code can take advantage of the hardware offload/encap
available in merchant silicon.  The general idea seems to add the
knowledge of offload hardware to the kernel -- either via new ndo_ops or
netlink.  This gives users who have this hardware the ability to have a
solution for their router/switch that makes it feel like Linux is
actually helping make forwarding decisions -- rather than just being the
kernel chosen to provide an environment where some other non-community
code runs that makes all of the decisions.

And now we also have the patchset that spawned what I think has been
more excellent discussion.  Jiri and Scott's patches bring up another,
more generic model that while not currently backed by hardware provided
an example/vision for what could be done if such hardware existed and
how to consider interacting with that driver/hardware (that clearly has
been met with some resistance, but the discussion has been great).
There ultimate goals appear to be similar to those that want full
offload/fordwarding support for a device, but via a different method
than what some would consider standard.

I am personally hopeful that most who are passionate about this will be
able to get together next month at LPC (or send someone to represent
them!) so that those interested can sit in the same room and try to
better understand each others desires and start to form some concrete
direction towards a solution that seems to meet the needs of most while
not being an architectural disaster.

Of course that may be way too optimistic for this crowd!  :-D
