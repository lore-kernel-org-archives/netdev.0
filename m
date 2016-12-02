From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: arp_filter and IPv6 ND
Date: Fri, 2 Dec 2016 15:08:45 +0100
Message-ID: <3bf09622-afa5-506c-8407-e3e1a70341c0@stressinduktion.org>
References: <CAAeewD82Lfo7c=vLHR7p3oxJ8d0OgWrijKmNn8EPFKq7fN7AMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Saku Ytti <saku@ytti.fi>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:58655 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761920AbcLBOJG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 09:09:06 -0500
In-Reply-To: <CAAeewD82Lfo7c=vLHR7p3oxJ8d0OgWrijKmNn8EPFKq7fN7AMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.12.2016 13:51, Saku Ytti wrote:
> net.ipv4.conf.all.arp_filter appears not to have IPv6 counter part.
> Or am I missing something? That is Linux does answer to ND queries for
> unrelated interfaces by default, and I can't seem to find way to turn
> that off.

May I ask why you want to turn it off?

In IPv6 this depends on the scope. In IPv4 this concept doesn't really
exist.

Please notice that in IPv4 arp_filter does not necessarily mean that the
system is operating in strong end system mode but you end up in an
hybrid clone where arp is acting strong but routing not and thus you
also have to add fib rules to simulate that.

> Is it proper maintainership to accept changes to single protocol,
> without mandating the support for other protocol having same
> behavioural characteristics?
> 
> It is good that some parts for ARP and ND have common code in linux
> (neighbour.c) unlike in BSD where everything seems to be
> self-contained.
>
> I'd wish that even more of ARP/ND would common, because there are
> still lot of common behavioural code in ARP/ND code itself, which
> requires double maintenance and are implemented by different people at
> different times, so leads to different set of bugs and behaviour for
> same intended behaviour.
> 
> For example this feature should be protocol agnostic, developer should
> only need to develop it once for the higher level behavioural code,
> without minding which IP AFI it is for. Obviously that does not
> exclude ability to sysctl configure it on/off per AFI.
