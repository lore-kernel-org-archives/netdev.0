From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [patch net-next v2 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Wed, 12 Nov 2014 22:31:06 -0800
Message-ID: <5464502A.20103@intel.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <5460319B.2010605@mojatatu.com> <20141110034612.GB17246@vergenet.net> <5460391C.3010107@mojatatu.com> <20141110045830.GC17246@vergenet.net> <54613AD3.7030600@gmail.com> <20141113054412.GA31283@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Simon Horman <simon.horman@netronome.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:34642 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbaKMGb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 01:31:58 -0500
In-Reply-To: <20141113054412.GA31283@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/2014 09:44 PM, Simon Horman wrote:
> [snip]
>=20
>> Simon, if your feeling adventurous any feedback on the repo link
>> would be great. I still need to smash the commit log into something
>> coherent though at the moment you can see all the errors and rewrite=
s,
>> etc as I made them.
>=20
> Hi John,
>=20
> here is some preliminary feedback:
>=20
> * I notice that the parse graph code isn't present yet.
>   I suppose this is a difficult piece that naturally follows many
>   other piece. None the less it is possibly the piece of most
>   interest to me :-)

I can add this over the next few days. Also I wanted to publish some
more complex examples on top of rocker switch. The nic drivers are
interesting but not as complex as some of the switch devices.

There is also the table graph layout which I wanted tweak a bit. At
the moment I have hardware that can run tables in parallel and some
that executes tables in sequence. It might not be clear from the code
(why I need the cleanup) but the source id is being used to indicate
if the tables are executed in parallel or not.

>=20
> * Will del and update flows require flows to already exist?
>   And similarly, will add flow require flows with the same match to n=
ot
>   already exist?  If so, the error handling seems tricky of more than=
 one
>   flow is to be deleted/updated. IIRC there was some discussion of th=
at
>   kind of issue at the (double) round table discussion on the last da=
y of
>   LPC14 in D=C3=BCsseldorf.

I would expect del/updates for flows that don't exist should fail.

I didn't intend to add any checks in the kernel to verify the matches
are unique. My opinion on this is that user space shouldn't add new
duplicate flows. And if it does hardware resources will be wasted.

>=20
> * Should the .node_count value of ixgbe_table_node_l2 be 3?
>   ixgbe_table_graph_nodes has three elements but perhaps you
>   are intentionally excluding the last element ixgbe_table_node_nil?
>=20

Actually I could just drop the node_count at the moment because I've
been null terminating the arrays with null items.

I should either add a count field to all the structures or null termina=
te
the arrays. For now I mostly null terminate the arrays when I use
them. For example matches is null terminates same for actions.

=2EJohn
