From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Fri, 26 Sep 2014 23:03:01 +0300
Message-ID: <CAJ3xEMj0L_09ORvJhHPbcHociCsPN=H9QWui4BhnbWXSFzXDvA@mail.gmail.com>
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
	<20140924133246.GB4966@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
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
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36272 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbaIZUDC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 16:03:02 -0400
Received: by mail-ob0-f175.google.com with SMTP id m8so10514730obr.6
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 13:03:01 -0700 (PDT)
In-Reply-To: <20140924133246.GB4966@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 4:32 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/23/14 at 06:32pm, Or Gerlitz wrote:
>> Indeed.
>>
>> The idea is to leverage OVS to manage eSwitch (embedded NIC switch) =
as well
>> (NOT to offload OVS).
>>
>> We envision a seamless integration of user environment which is base=
d on OVS
>> with SRIOV eSwitch and the grounds for that were very well supported=
 in
>> Jiri=E2=80=99s V1.
>
> Please consider comparing your model with what is described here [0].
> I'm trying to write down an architecture document that we can finaliz=
e
> in D=C3=BCsseldorf.
> [0] http://goo.gl/qkzW5y

Yep, this can serve us for the architecture discussion @ LPC. Re the
SRIOV case, you referred to the case where guest VF traffic goes
through HW (say) VXLAN encap/decap -- just to make sure, we need also
to support the simpler case, where guest traffic just goes through
vlan tag/strip.


>> The eSwitch hardware does not need to have multiple tables and =E2=80=
=98enjoys=E2=80=99 the
>> flat rule of OVS. The kernel datapath does not need to be aware of t=
he
>> existence of HW nor its capabilities, it just pushes the flow also t=
o the
>> switchdev which represents the eSwitch.

> I think you are saying that the kernel should not be required to make
> the offload decision which is fair. We definitely don't want to force
> the decision to be outside though, there are several legit reasons to
> support transparent offloads within the kernel as well outside of OVS=
=2E
>
>> Yep. LPC is the time and place to go over the multiple use-cases (ph=
yiscal
>> switch, eSwitch, eBPF, etc) that could (should) be supported by the =
basic
>> framework.
>
> For reference:
> http://www.linuxplumbersconf.org/2014/ocw/proposals/2463

The SRIOV case is only mentioned here in the "Compatibility with
existing FDB ioctls for SR-IOV" bullet, so I'm a bit nervous... we
need to have it clear in the agenda. Also, this BoF needs to be
double-len, two hours, can you act to get that done?

thanks,

Or.
