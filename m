From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC] net: store port/representative id in metadata_dst
Date: Fri, 23 Sep 2016 11:06:09 +0200
Message-ID: <20160923110609.2f221f99@griffin>
References: <1474572417-15907-1-git-send-email-jakub.kicinski@netronome.com>
        <20160923063429.GA1821@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        ogerlitz@mellanox.com, John Fastabend <john.fastabend@gmail.com>,
        sridhar.samudrala@intel.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, Paolo Abeni <pabeni@redhat.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        hannes@stressinduktion.org, kubakici@wp.pl
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54942 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965614AbcIWJGT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 05:06:19 -0400
In-Reply-To: <20160923063429.GA1821@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Sep 2016 08:34:29 +0200, Jiri Pirko wrote:
> So if I understand that correctly, this would need some "shared netdev"
> which would effectively serve only as a sink for all port netdevices to
> tx packets to. On RX, this would be completely avoided. This lower
> device looks like half zombie to me.

Looks more like a quarter zombie. Even tx would not be allowed unless
going through one of the ports, as all skbs without
METADATA_HW_PORT_MUX metadata_dst would be dropped. But it would be
possible to attach qdisc to the "lower" netdevice and it would actually
have an effect. On rx this netdevice would be ignored completely. This
is very weird behavior.

> I don't like it :( I wonder if the
> solution would not be possible without this lower netdev.

I agree. This approach doesn't sound correct. The skbs should not be
requeued.

 Jiri
