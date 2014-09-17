From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch net-next 01/13] openvswitch: split flow structures into
 ovs specific and generic ones
Date: Wed, 17 Sep 2014 15:07:27 -0700
Message-ID: <CAEP_g=-3JxrG0Ho0pmkFqgZos4nmAdmY85EFn0qE7cO1PsmZ5A@mail.gmail.com>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <1409736300-12303-2-git-send-email-jiri@resnulli.us> <CALnjE+pscRmfhaWgkWCunJfjvG04RiNUAj6nefSFHrknQTC+xw@mail.gmail.com>
 <20140904123323.GF1867@nanopsycho.lan> <CALnjE+qwbQ=5wsLddvZX95xE2_U=osuDg8S10zKWarMD9mp4Aw@mail.gmail.com>
 <20140917083421.GB1863@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	nhorman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"jeffrey.t.kirsher" <jeffrey.t.kirsher@intel.com>,
	vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"john.r.fastabend" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	sfeldma <sfeldma@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	jasowang <jasowang@redhat.com>, ebie
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:40704 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755998AbaIQWHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 18:07:48 -0400
Received: by mail-qa0-f52.google.com with SMTP id m5so2951qaj.11
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 15:07:47 -0700 (PDT)
In-Reply-To: <20140917083421.GB1863@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 1:34 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Sep 04, 2014 at 10:46:28PM CEST, pshelar@nicira.com wrote:
>>On the other hand if vswitchd uses common interface (switchdev) there
>>is no need to extend ovs kernel interface. For example specifying
>>extra metadata, like (sw only, hw olny, both).
>
> I understand you point of view. However from the offloading perspective
> it makes much more sense to push the flows through a single interface
> (ovs genl) and only offload selected flows to hw (pushing further).
> Having vswitchd to handle 2 different ifaces for the same/similar thing
> does not seem like a clean solution to me. And it really breaks the
> offloading view.
>
> Plus the amount of code needed to be pushed into ovs kernel dp code in
> order to enable this is small.

This is missing the point: software forwarding and a hardware driver
interface are doing totally different things. Over time, these will
diverge and you will essentially up with two separate paths packed
together which doesn't help anything. This is not a theoretical
concern as different directions either already exist or have been
proposed. On the software side, there is the BPF proposal which is not
likely to map to hardware any time soon. On the other hand, hardware
is usually composed of multiple tables/functions with varying
capabilities. Sooner or later you will want to take advantage of these
and doing so isn't really possible with the software optimized flows
that the kernel handles. At that point, you will likely introduce a
new interface to userspace to expose this and get flows processed in a
different way.
