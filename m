From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next v2 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Thu, 13 Nov 2014 14:44:14 +0900
Message-ID: <20141113054412.GA31283@vergenet.net>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <5460319B.2010605@mojatatu.com>
 <20141110034612.GB17246@vergenet.net>
 <5460391C.3010107@mojatatu.com>
 <20141110045830.GC17246@vergenet.net>
 <54613AD3.7030600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
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
	gospo@cumulusn
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:43506 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753621AbaKMFoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 00:44:39 -0500
Received: by mail-pa0-f52.google.com with SMTP id fa1so14485453pad.25
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 21:44:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54613AD3.7030600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

> Simon, if your feeling adventurous any feedback on the repo link
> would be great. I still need to smash the commit log into something
> coherent though at the moment you can see all the errors and rewrites=
,
> etc as I made them.

Hi John,

here is some preliminary feedback:

* I notice that the parse graph code isn't present yet.
  I suppose this is a difficult piece that naturally follows many
  other piece. None the less it is possibly the piece of most
  interest to me :-)

* Will del and update flows require flows to already exist?
  And similarly, will add flow require flows with the same match to not
  already exist?  If so, the error handling seems tricky of more than o=
ne
  flow is to be deleted/updated. IIRC there was some discussion of that
  kind of issue at the (double) round table discussion on the last day =
of
  LPC14 in D=C3=BCsseldorf.

* Should the .node_count value of ixgbe_table_node_l2 be 3?
  ixgbe_table_graph_nodes has three elements but perhaps you
  are intentionally excluding the last element ixgbe_table_node_nil?
