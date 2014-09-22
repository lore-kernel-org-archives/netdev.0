From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Mon, 22 Sep 2014 23:17:27 +0100
Message-ID: <20140922221727.GA4708@casper.infradead.org>
References: <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com>
 <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com>
 <541CAA3C.5080105@intel.com>
 <20140920081426.GE1821@nanopsycho.orion>
 <20140920105354.GA29419@casper.infradead.org>
 <CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
 <20140922081341.GA20905@casper.infradead.org>
 <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
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
Received: from casper.infradead.org ([85.118.1.10]:56706 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487AbaIVWRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 18:17:37 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/14 at 08:10am, Tom Herbert wrote:
> Thomas, can you (or someone else) quantify what the host case is. I
> suppose there may be merit in using a switch on NIC for kernel bypass
> scenarios, but I'm still having a hard time understanding how this
> could be integrated into the host stack with benefits that outweigh

Personally my primary interest is on lxc and vm based workloads w/
end to end encryption, encap, distributed L3 and NAT, and policy
enforcement including service graphs which imply both east-west
and north-south traffic patterns on a host. The usual I guess ;-)

> complexity. The history of stateful offloads in NICs is not great, and
> encapsulation (stuffing a few bytes of header into a packet) is in
> itself not nearly an expensive enough operation to warrant offloading

No argument here. The direct benchmark comparisons I've measured showed
only around 2% improvement.

What makes stateful offload interesting to me is that the final
desintation of a packet is known at RX and can be redirected to a
queue or VF. This allows to build packet batches on shared pages
while preserving the securiy model.

Will the gains outweigh complexity? I hope so but I don't know for
sure. If you have insights, let me know. What I know for sure is that
I don't want to rely on a kernel bypass for the above.

> to the NIC. Personally, I wish if NIC vendors are going to focus on
> stateful offload I rather see it be for encryption which I believe
> currently does warrant offload at 40G and higher speeds.

Agreed. I would like to be see a focus on both.
