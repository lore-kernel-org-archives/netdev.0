From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next 03/22] ipv4: support for fib route lwtunnel encap
 attributes
Date: Fri, 10 Jul 2015 17:36:56 +0200
Message-ID: <1436542616.24939.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1436537414.git.tgraf@suug.ch>
	 <8ebc9066754f07003d54c3ac64d8c46f9c1c570b.1436537414.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:35205 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754765AbbGJPhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 11:37:00 -0400
Received: by wgjx7 with SMTP id x7so252290553wgj.2
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 08:36:58 -0700 (PDT)
In-Reply-To: <8ebc9066754f07003d54c3ac64d8c46f9c1c570b.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-10 at 16:19 +0200, Thomas Graf wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>


> +	if (oif)
> +		dev = __dev_get_by_index(net, oif);
> +	ret = lwtunnel_build_state(dev, encap_type,
> +				   encap, &lwtstate);
> +	if (!ret) {
> +		lwtunnel_state_get(lwtstate);
> +		ret = lwtunnel_cmp_encap(lwtstate, nh->nh_lwtstate);
> +		lwtunnel_state_put(lwtstate);
> +
> +		return ret;


These _get()/_put() calls do not seem necessary, or buggy.

If refcounting is needed the _get() should be done at the time lwstate
is fetched.
