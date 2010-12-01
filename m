From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] Net-ethtool : Allow ethtool to set interface in
 loopback mode.
Date: Wed, 01 Dec 2010 14:54:15 +0000
Message-ID: <1291215255.3170.12.camel@bwh-desktop>
References: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
	 <1291129305.21077.9.camel@bwh-desktop>
	 <AANLkTikM4=yOu9L7h0FZUkmMNG-LVdGsdSLOLJmw2+UW@mail.gmail.com>
	 <1291144507.21077.56.camel@bwh-desktop>
	 <AANLkTik=YkC6w3d2ViOqH5AYcxfRB6eKx3Mk_6=aKXGH@mail.gmail.com>
	 <AANLkTimJJzQ6f06CoWJuofwS0m2Bn3gAcfWTOEiYyjEZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	laurent chavey <chavey@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12989 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab0LAOyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 09:54:18 -0500
In-Reply-To: <AANLkTimJJzQ6f06CoWJuofwS0m2Bn3gAcfWTOEiYyjEZ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-30 at 15:57 -0800, Mahesh Bandewar wrote:
> This patch enables ethtool to set the loopback mode on a given
> interface. By configuring the interface in loopback mode in conjunction
> with a policy route / rule, a userland application can stress the egress /
> ingress path exposing the flows of the change in progress and potentially
> help developer(s) understand the impact of those changes without even
> sending a packet out on the network.
[...]
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -616,6 +616,17 @@ void ethtool_ntuple_flush(struct net_device *dev);
>   *     Should validate the magic field.  Don't need to check len for zero
>   *     or wraparound.  Update len to the amount written.  Returns an error
>   *     or zero.
> + *
> + * get_loopback:
> + * set_loopback:
> +    These are the driver specific get / set methods to report / enable-
> +       disable loopback mode. The idea is to stress test the ingress / egress
> +       paths by enabling this mode. There are multiple places this could be
> +       done and choice of place will most likely be affected by the device
> +       capabilities. So as a guiding principle; select a place to implement
> +       loopback mode as close to the host as possible. This would maximize the
> +       soft-path length and maintain parity in terms of comparison with differe
> +       set of drivers.
[...]

I know this is nitpicking, but the comment should have asterisks (*)
repeated down the left edge.  Also, a typo: "differe" should be
"different".

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

