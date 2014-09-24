From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Wed, 24 Sep 2014 14:32:46 +0100
Message-ID: <20140924133246.GB4966@casper.infradead.org>
References: <541CAA3C.5080105@intel.com>
 <20140920081426.GE1821@nanopsycho.orion>
 <20140920105354.GA29419@casper.infradead.org>
 <CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
 <20140922081341.GA20905@casper.infradead.org>
 <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
 <CAADnVQKhUAR=qVg9q82ngYMzQnoDVbq+wupzdMrH8WiCeMiU4A@mail.gmail.com>
 <CA+mtBx-mJE6SW2bqf3_t6iu=o5FY1WAF1ByeZpDJnc+6fpK6nA@mail.gmail.com>
 <20140923041130.GA10808@gospo.home.greyhouse.net>
 <542192A3.2020309@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Tom Herbert <therbert@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
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
	Florian Fainelli <f.fainelli@gmail.co
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40943 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbaIXNcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 09:32:52 -0400
Content-Disposition: inline
In-Reply-To: <542192A3.2020309@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/14 at 06:32pm, Or Gerlitz wrote:
> Indeed.
>=20
> The idea is to leverage OVS to manage eSwitch (embedded NIC switch) a=
s well
> (NOT to offload OVS).
>=20
> We envision a seamless integration of user environment which is based=
 on OVS
> with SRIOV eSwitch and the grounds for that were very well supported =
in
> Jiri=E2=80=99s V1.

Please consider comparing your model with what is described here [0].
I'm trying to write down an architecture document that we can finalize
in D=C3=BCsseldorf.

[0] http://goo.gl/qkzW5y

> The eSwitch hardware does not need to have multiple tables and =E2=80=
=98enjoys=E2=80=99 the
> flat rule of OVS. The kernel datapath does not need to be aware of th=
e
> existence of HW nor its capabilities, it just pushes the flow also to=
 the
> switchdev which represents the eSwitch.

I think you are saying that the kernel should not be required to make
the offload decision which is fair. We definitely don't want to force
the decision to be outside though, there are several legit reasons to
support transparent offloads within the kernel as well outside of OVS.

> Yep. LPC is the time and place to go over the multiple use-cases (phy=
iscal
> switch, eSwitch, eBPF, etc) that could (should) be supported by the b=
asic
> framework.

=46or reference:
http://www.linuxplumbersconf.org/2014/ocw/proposals/2463
