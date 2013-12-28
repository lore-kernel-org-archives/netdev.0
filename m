From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: bridge vlan_filtering don't work with tap devices (qemu guests)
Date: Sat, 28 Dec 2013 22:00:31 +0900
Message-ID: <1388235631.1754.23.camel@localhost.localdomain>
References: <ecd32790-8561-4b95-9e2f-2e5aad97d8fe@mailpro>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>
To: Alexandre DERUMIER <aderumier@odiso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:50630 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755324Ab3L1NAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 08:00:39 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so10129591pab.21
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 05:00:38 -0800 (PST)
In-Reply-To: <ecd32790-8561-4b95-9e2f-2e5aad97d8fe@mailpro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-27 at 17:17 +0100, Alexandre DERUMIER wrote:
> Little update: 
> 
> I can see now tagged packet on br0 with tcpdump, if I have
> 
> #bridge vlan add dev br0 vid 10 self.
> 
> All is working fine now.
> 
> I have a last question : 
> 
> Is it possible to allow all vlans to go through a port. (or disable filtering for 1 specific port) ?

AFAIK, it is impossible.

> 
> If not, maybe could be it great to be able to add multiple vlans with bridge command,like 
> "bridge vlan add dev xxx vid 1-4096"
> or
> "bridge vlan add dev xxx vid 1,2,3-10,12,13-4096"

Such commands seem to be not supported yet.

> 
[...]
> >>Or didn't you set br0 in the same way as other ports like below? 
> >># bridge vlan add dev br0 vid 10 pvid untagged self 
> 
> Indeed I didn't set vlan on br0. Isn't it only to tag packets coming from the bridge itself? (like a bridge management ip for example). 
> Or do we need to define all vlans allowed to pass through the bridge ? 

If br0 is promiscuous mode, you should be able to see all frames going
through the bridge.
But if vid 10 untagged is set on br0, incoming frames with vid 10 will
be seen after untagged.

If br0 is not promisc mode, you can see only packets delivered to or
transmitted from br0.

tcpdump normally puts a device into promisc mode, without -p option.

You don't need to add all vids to pass through the bridge.
Settings on br0 will affect only frames coming from or going to br0.

Thanks,
Toshiaki Makita
