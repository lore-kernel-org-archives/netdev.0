From: Edward Cree <ecree@solarflare.com>
Subject: [BISECTED] Re: Strange ARP behaviour with VXLAN
Date: Tue, 7 Feb 2017 12:12:38 +0000
Message-ID: <bffca5c4-476a-5f4b-e2f0-201e425428cf@solarflare.com>
References: <8d73b8f8-0ac4-c4c1-4dfc-c120716d52df@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@ovn.org>, Jiri Benc <jbenc@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:13336 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752624AbdBGMMr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 07:12:47 -0500
In-Reply-To: <8d73b8f8-0ac4-c4c1-4dfc-c120716d52df@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/17 16:20, Edward Cree wrote:
> [ Specific kernel version: 624374a56419c2d6d428c862f32cc1b20519095d.
> Note that if I do the same on 3.10.327-el7.x86_64 (RHEL7u2) the problem
> does not occur.  I have not yet tested on older mainline kernels, but plan
> to do so shortly.  Also note that in both cases, the link partner is running
> 3.10.327-el7.x86_64. ]
I've now bisected this to 272d96a5ab10 "net: vxlan: lwt: Use source ip address
 during route lookup."  Which is interesting, because I'm using a vxlan
 netdevice, not an LWT; maybe in the former case the saddr is bogus.
Presumably the route lookup gets cached and that's why it remembers the broken
 state.

-Ed
