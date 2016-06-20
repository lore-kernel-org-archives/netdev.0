From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Mon, 20 Jun 2016 15:09:43 +0200
Message-ID: <20160620130943.GC2043@nanopsycho.orion>
References: <20160616.172632.1759391103978744570.davem@davemloft.net>
 <20160617082411.GA1981@nanopsycho.orion>
 <f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
 <20160617140512.GB1981@nanopsycho.orion>
 <57640F2A.7090003@mojatatu.com>
 <9f8e85ac-3e96-257e-cf7f-e7e793d41cf4@cumulusnetworks.com>
 <20160617154243.GD1981@nanopsycho.orion>
 <57642F76.6090403@gmail.com>
 <CAJieiUhFRp6wE_gt-0q9KYQTYdEyg5yFUYa89K+ovaQr7QE5Zg@mail.gmail.com>
 <5767E16F.2040902@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nogah Frankel <nogahf@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>, sd@queasysnail.net,
	eranbe@mellanox.com, Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33430 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503AbcFTNJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 09:09:51 -0400
Received: by mail-wm0-f67.google.com with SMTP id r201so13977773wme.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 06:09:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5767E16F.2040902@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 20, 2016 at 02:28:31PM CEST, jhs@mojatatu.com wrote:
>On 16-06-19 11:14 PM, Roopa Prabhu wrote:
>>On Fri, Jun 17, 2016 at 10:12 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>
>
>>
>>I have also mentioned this before, the default api must provide
>>accumulated (hw and sw) stats...,
>>because this is the api that the user queries on an interface.
>
>Sorry - I missed those discussions.
>What is current practise? Do people request for one via ip link
>stats and the other via ethtool?

Yes.


>What do you guys do in your implementation?

Currently we do what you described. This patchset changes it.


>Yes, it would be more accurate to provide aggregated stats but
>it may break backward compat if expectation is both are read
>separately today.
>Maybe it makes sense to have a brand new TLV for these aggregated
>stats as Jiri was suggesting.That means two new TLVs not one.
>1) TLV for aggregated stats - which cant be current one
>2) TLV for h/w stats
>
>The existing stat implies s/ware only.


What is "aggregated"? if hw counts it, sw counts it as well.
HW stats are in fact aggregated. It includes all.

Apps should see HW stats as they don't care if the forwarding is
offloaded to HW or not. And if someone is aware there is a forward
offload, he can query sw-only stats via iface proposed by this patchset.
