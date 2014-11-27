From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Thu, 27 Nov 2014 12:13:18 +0900
Message-ID: <20141127031315.GD1649@vergenet.net>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-5-git-send-email-jiri@resnulli.us>
 <5474A567.4040401@mojatatu.com>
 <20141125164954.GJ1971@nanopsycho.orion>
 <5474B795.3080204@mojatatu.com>
 <20141125215402.GA3912@casper.infradead.org>
 <54754A10.6020601@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:64552 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbaK0DNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 22:13:43 -0500
Received: by mail-pd0-f181.google.com with SMTP id z10so4030492pdj.12
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 19:13:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54754A10.6020601@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 10:33:36PM -0500, Jamal Hadi Salim wrote:
> On 11/25/14 16:54, Thomas Graf wrote:
> >On 11/25/14 at 12:08pm, Jamal Hadi Salim wrote:
>=20
> >It would definitely help if you could expose some more details on th=
e
> >"some network processor" you have. We're all very eager ;-)
> >
>=20
> Well, this thing doesnt run ovs ;-> (/me runs). If you come
> to netdev i may let you play with it ;-> Its a humongous device
> (think multi 100G ports).
>=20
> On a serious note: Even if you took what Simon/Netronome has
> (yes, I know they use ovs;->)

=46WIW, we are also interested in non-OVS use cases.

> - there is really no need for a switch
> abstraction *at all* if all you want to is hang a packet
> processing graph that ingresses at a port and egress at another port.
> As you know, Linux supports it just fine with tc.

I may be missing the point but I see two problems that are solved by
the switch abstraction.

- Cases where no ports are configured.

  Perhaps no such use cases exist for the API in question.
  But it does seem plausible to me that non-physical ports could
  be added at run-time and that thus a "switch" could initially
  exist with no configured port. Something like how bridges
  initially have no ports (IIRC).

- Discovering the association between ports and "switches".

My recollection from the double round table discussion on the last day =
of
the D=C3=BCsseldorf sessions was that these were reasons that simply ac=
cessing
any port belonging to the "switch" were not entirely satisfactory.

> >I'm with Jiri but I agree it's not a perfect fit. I doubt there is b=
ut
> >if you can come up with something that fits better I'm open to it.
> >
> >I considered "dataplane" or "dp" for a bit but it's quite generic as
> >well.
> >
>=20
> The purpose is to offload. I think any name would be better than
> mapping it to a specific abstraction called "switch". Especially
> if it is hanging off a port and there is no switch in the pipeline.
>=20
> cheers,
> jamal
