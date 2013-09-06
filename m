From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GSO/GRO and UDP performance
Date: Fri, 06 Sep 2013 12:32:35 -0700
Message-ID: <1378495955.31445.52.camel@edumazet-glaptop>
References: <52270659.1090208@openvpn.net>
	 <1378295631.7360.98.camel@edumazet-glaptop> <52299EDD.1030208@openvpn.net>
	 <1378472829.31445.21.camel@edumazet-glaptop> <522A05E9.3090206@hp.com>
	 <522A2C76.10203@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, netdev <netdev@vger.kernel.org>
To: James Yonan <james@openvpn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:37733 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664Ab3IFTcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 15:32:36 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so3602253pbc.16
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 12:32:36 -0700 (PDT)
In-Reply-To: <522A2C76.10203@openvpn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 13:26 -0600, James Yonan wrote:

> Where does the 16+1 come from?  I'm getting my 43x from the ratio of max 
> legal IP packet size (64KB) / internet MTU (1500).  Are you saying that 
> GRO cannot aggregate up to 64 KB?
> 

Yes this is what I said.

Hint : MAX_SKB_FRAGS is the number of fragments per skb

Each aggregated frame consumes at least one fragment.

Hint : some drivers uses more than one fragment per datagram.

-> A fragment in skb does not necessarily contains one and exactly one
datagram

> >> I think we cannot aggregate UDP packets, because UDP lacks sequence
> >> numbers, so reorders would be a problem.
> 
> >> You really need something that is not UDP generic.
> 
> Right -- that's why I'm proposing a hook for UDP GSO/GRO providers that 
> know about specific app-layer protocols and can provide segmentation and 
> aggregation methods for them.  Such a provider would be implemented in a 
> kernel module and would know about the specific app-layer protocol, so 
> it would be able to losslessly segment and aggregate it (i.e. it could 
> use a sequence number from the app-layer protocol).

Its not a choice given by application.

As I said you'll have to make sure all the stack will understand the
meaning of datagram aggregation.
