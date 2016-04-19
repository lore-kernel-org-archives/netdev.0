From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Tue, 19 Apr 2016 10:54:40 -0700
Message-ID: <1461088480.10638.221.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5716338E.4050003@solarflare.com>
	 <5716347D.3030808@solarflare.com>
	 <1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALx6S34ZFFFZVn2_ugp+eQg6QhdHj=CWPuvW3s9aC2dg75nqiQ@mail.gmail.com>
	 <57166719.4070209@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34498 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933531AbcDSRyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 13:54:40 -0400
Received: by mail-pf0-f169.google.com with SMTP id c20so8992002pfc.1
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 10:54:40 -0700 (PDT)
In-Reply-To: <57166719.4070209@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-19 at 18:12 +0100, Edward Cree wrote:

> I think if we pushed bundled RX all the way up to the TCP layer, it might
> potentially also be faster than GRO, because it avoids the work of
> coalescing superframes; plus going through the GRO callbacks for each
> packet could end up blowing icache in the same way the regular stack does.
> If bundling did prove faster, we could then remove GRO, and overall
> complexity would be _reduced_.

Oh well. You really are coming 8 years too late.

I receive ~40 Gbit on a _single_ TCP flow with GRO, I have no idea what
you expect to get without GRO, but my educated guess is :

It will be horrible, and will add memory overhead. (remember GRO shares
a single sk_buff/head for all the segs)

And as a bonus, GRO works also on forwarding workloads, when this packet
is delivered to another NIC or a virtual device.

Are you claiming TSO is useless ?

It is not because a model works well in some other stack (userspace I
guess), that we have to copy it in linux kernel.

Feel free to experiment things, but if your non GRO solution is slower
than GRO, don't even mention it here.

Remember to test things with a realistic iptables setup.
