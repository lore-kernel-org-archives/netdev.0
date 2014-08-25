From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Mon, 25 Aug 2014 23:11:48 +0100
Message-ID: <20140825221148.GC30140@casper.infradead.org>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com>
 <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com>
 <20140825145449.GB30140@casper.infradead.org>
 <53FB68EB.9060308@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46363 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997AbaHYWLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:11:55 -0400
Content-Disposition: inline
In-Reply-To: <53FB68EB.9060308@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all, thanks for the animated discussion, wouldn't
want to miss our arguments ;-)

On 08/25/14 at 12:48pm, Jamal Hadi Salim wrote:
> On 08/25/14 10:54, Thomas Graf wrote:
> >On 08/24/14 at 11:15am, Jamal Hadi Salim wrote:
> 
> >Let's keep vendors out of this discussion.
> 
> The API is from a vendor. It is clearly labelled as an OF API.
> It covers well abstracting that vendors SDK to enable OF. That
> is relevant info.
> If it covers all other vendors (which is where
> the quark handling comes in), I will be fine with it.
> I dont believe it does.

If I understand you correctly you are referring to the rocker
patch here. That is not part of the API.
 
> >That is simply not the case. The fact that John is using this model
> >to replace the flow director ioctl API should prove this.
> 
> depends what NIC classifier John is mapping to. The Intels have
> about 4-5 different types of classifier on different hardware

Sorry for not addressing this but I think John should speak for
himself here, I don't want to misrepresent his plans.

> I gave a simple example.
> There are a hell more quarks than that.
> There are cases where there are multiple tables in terms of net masks
> etc.
> Yes, this should be handled in the driver. The input is the route
> message we already specify and not some XXX_Flow_XXx struct.

I would argue that swflow is a superset of a Netlink route. It
may infact be very useful to extend the API with something that
understands the Netlink representation of a route and have the
API translate that to a classifier that can be offloaded.

> I would be tagging along with you guys for flows if you:
> a) allow for different classifiers. This allows me to implement
> u32 and offload it.

Agreed. What you seem to disagree on is:

 - ndo_add_type1([...])
 - ndo_add_type2([...])
 - ndo_add_type3([...])

vs.

 - ndo_add_classifier(type, [...])

I honestly have little against the 2nd. It sounds a bit like an
ioctl interface though where a giant switch statement will cast
the data to a classifier specific struct which is why I slightly
dislike it.

It looks to me that a specific chip may either work in a flow/filter
mode, in a generic programmable mode or by providing a list of very
specific filters without a generic flow -> action relation. Having
multiple classifier types for all of them gives the impression that
an API user could use them in any combination which I would say will
typically not be the case.

> b) different actions (I think this part is not controversial, you
> seem to be having it already).

Agreed
