From: Saku Ytti <saku@ytti.fi>
Subject: Re: arp_filter and IPv6 ND
Date: Fri, 2 Dec 2016 17:42:38 +0200
Message-ID: <CAAeewD_2tfNHhWmtwXb_28DicmipReimRvGqv1Q6PQ0AjkBPGw@mail.gmail.com>
References: <CAAeewD82Lfo7c=vLHR7p3oxJ8d0OgWrijKmNn8EPFKq7fN7AMg@mail.gmail.com>
 <3bf09622-afa5-506c-8407-e3e1a70341c0@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:36135 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750862AbcLBPvh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 10:51:37 -0500
Received: by mail-vk0-f45.google.com with SMTP id p9so147799792vkd.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 07:51:36 -0800 (PST)
In-Reply-To: <3bf09622-afa5-506c-8407-e3e1a70341c0@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2 December 2016 at 16:08, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:

Hey,

> May I ask why you want to turn it off?

Certainly. I don't want device to answer with link address for L3
address it does not have on the link. In my case it triggers this bug
https://supportforums.cisco.com/document/12098096/cscse46790-cef-prefers-arp-adjacency-over-rib-next-hop

In this particular case, for one reason or another my Cisco device
would have ND entry for Linux loopback pointing to an interface with
completely different network.  Which itself would be just weird, but
combined with weird behaviour of Cisco it actually causes the loopback
route advertised by BGP not to be installed. If the ND entry didn't
exist, the BGP route would be installed.
I don't really even know why the ND entry exists, all I can think of
is that Linux must have sent gratuitous reply, because I don't se why
Cisco would have tried to discover it.

Expected behaviour is that the loopback/128 BGP route resolves to
on-link next-hop, and on-link next hop is then ND'd. Observed
behaviour is that loopback/128 BGP route also appears in ND cache.

> In IPv6 this depends on the scope. In IPv4 this concept doesn't really
> exist.
>
> Please notice that in IPv4 arp_filter does not necessarily mean that the
> system is operating in strong end system mode but you end up in an
> hybrid clone where arp is acting strong but routing not and thus you
> also have to add fib rules to simulate that.

It's just very peculiar behaviour to have ARP or ND entries on a
interface where given subnet does not exist, it rudimentarily causes
difficult to troubleshoot problems and is surprising/unexpected
behaviour.
Of course well behaving device wouldn't accept such replies, because
it itself could be attack vector (imagine me telling you 8.8.8.8 is on
the link, or worse, your bank).

I'm curious, why does this behaviour exist? When is this desirable?
I've never seen any other device than Linux behave like this, and when
ever I've heard about the problem, I've only seen surprised faces that
it does behave like this.
-- 
  ++ytti
