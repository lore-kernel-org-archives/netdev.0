From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [IPV6] addrconf: Fix IPv6 on tuntap tunnels
Date: Mon, 18 Jun 2007 13:56:26 -0400
Message-ID: <4676C74A.4010607@hp.com>
References: <20070614.130358.90120374.davem@davemloft.net> <467259DD.7030703@hartkopp.net> <4672F9AE.6070400@hp.com> <20070615.151457.98556461.davem@davemloft.net> <20070616075555.GA23905@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, oliver@hartkopp.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	koster@debian.org.tw, socketcan@hartkopp.net,
	urs@isnogud.escape.de, florz@florz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:45280 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756158AbXFRR4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 13:56:42 -0400
In-Reply-To: <20070616075555.GA23905@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Jun 15, 2007 at 03:14:57PM -0700, David Miller wrote:
>>> No, the questions should really be:
>>>
>>> 1.  Is IPV6 supported over this media type.
>>> 	yes: got to 2
>>> 	no:  stop
>>>
>>> 2.  Is the device MTU >= IPV6_MIN_MTU
>>> 	yes: continue
>>> 	no:  stop
>>>
>>> Autoconfiguration is a layer on top of IPv6.  Whether it's enabled
>>> or not should not dictate whether IPv6 addressed may be configured or not.
>> Sounds good to me, patches? :-)
> 
> I don't think we need any more patches since right now MTU >= IPV6_MIN_MTU
> is the only condition we require before we allow IPv6 addresses to be added
> to an interface.
> 
> The original patch simply confused this basic IPv6 address support with
> IPv6 autoconfiguration.

Looking over the history, Herbert has mostly right.

The only concern I have is that it's currently permitted to configure
IPv6 addresses on interface that would not have link-local addressing
(ex: IEEE 1394 link).

Now, is some circumstances that's ok (tuntap is a perfect example).
In others, particularly where there is an "IPv6 over foo" spec, not so much.

-vlad
