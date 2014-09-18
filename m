From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2 v2 nf-next] net: bridge: don't register netfilter call_iptables hooks by default
Date: Thu, 18 Sep 2014 21:52:28 +0200
Message-ID: <d77096fe-7341-41ab-b729-075396813fd3@email.android.com>
References: <1410969137-11885-1-git-send-email-fw@strlen.de> <20140918133511.GA8740@salvia> <20140918143108.GB8484@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34855 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785AbaIRTwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 15:52:44 -0400
In-Reply-To: <20140918143108.GB8484@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18. September 2014 16:31:08 MESZ, Florian Westphal <fw@strlen.de> wrote:
>Pablo Neira Ayuso <pablo@netfilter.org> wrote:

>> This patch modularizes br_netfilter so it can be
>> rmmod'ed, thus, the hooks can be unregistered.
>
>I see.  Yes, that makes sense.
>
>Another alternative would be to merge both approaches.
>I.e, use my patch, but move all the hook registration to
>your proposed br_nf_core module.
>
>The sysctls would still be registered from bridge.ko.
>
>Then, if call_iptables is set and iptables rules are active,
>do the module autoload and print the warning from your patch, telling
>people to modprobe br_nf_core if they want the filtering.
>
>Unfortunately, we'd have to export (from bridge.ko) some hook
>to allow br_nf_core to signal that the hooks have been registered.
>
>Then, in two years or so, we would remove the autoload hook
>in the packet procesing path.

I believe basically any transition which relies on people reading feature-removal-schedule or kernel messages and a flag day is just kidding ourselves and things will break for everyone except maybe some distributions at flag day.

I think taking compatibility seriously means we can't really change the default behaviour, but can only allow people to manually undo the damage and make sure they won't rely on this behaviour for at least nftables.

Or we can change it. But then why wait for two years, it won't change anything. 

Is there a way to make the userspace tools detect that the compat behaviour needs to be activated? 
