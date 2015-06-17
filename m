From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next 0/4] switchdev: avoid duplicate packet forwarding
Date: Wed, 17 Jun 2015 00:02:39 -0700
Message-ID: <CAE4R7bAKkcEQ51_=LuXc8FCtgQNxMrYuioYV0L_akNov37TmGA@mail.gmail.com>
References: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
 <20150615.162551.805611215439524288.davem@davemloft.net> <20150616060427.GA2135@nanopsycho.orion>
 <CAE4R7bDEw0JVkwagps1eBVGuZuK58eEfTX+0GU-2U1UKGCYyKQ@mail.gmail.com>
 <20150616211147.GB2135@nanopsycho.orion> <CAE4R7bA2ruG5MbExqC=TUiZdP9xjTvhSZxNV1kv+C4MfcG_1gA@mail.gmail.com>
 <20150617063002.GA2090@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	davidch <davidch@broadcom.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33222 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753494AbbFQHDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 03:03:01 -0400
Received: by obcej4 with SMTP id ej4so27294821obc.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 00:03:00 -0700 (PDT)
In-Reply-To: <20150617063002.GA2090@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2015 at 11:30 PM, Jiri Pirko <jiri@resnulli.us> wrote:

> Scott, again, I'm not talking about br0 ifindex! I'm talking about
> ifindexes of the port netdevs.
>
> br0
>   sw1p1  ifindex=1
>   sw1p2  ifindex=2
>   sw2p1  ifindex=3
>   sw2p2  ifindex=4
>
>
> now we have 2 groups, one in each switch. So for sw1 group (sw1p1 and
> sw1p2) we select mark one of the ifindexes, so either "1" or "2"
> For second group, from sw2 we select "3" or "4". So for example:
> br0
>   sw1p1  mark=1
>   sw1p2  mark=1
>   sw2p1  mark=4
>   sw2p2  mark=4
>
> This is generic, usable for every group.

Oooh, that's good.  I like it.  If the port is not grouped, set
mark=ifindex.  Or mark=0 to have a dflt group for ungrouped ports.

Do you see a way to code this up?  The only thing that comes to mind
is for the swX driver to keep track of mark picked for each bridge
brY, but I was hoping you have an idea how to do this without any
storage?
