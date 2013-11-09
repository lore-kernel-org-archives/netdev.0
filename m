From: Brian Haley <brian.haley@hp.com>
Subject: Re: iproute2: potential upgrade regression with 58a3e827
Date: Sun, 10 Nov 2013 01:00:34 +0800
Message-ID: <527E6A32.5020808@hp.com>
References: <527D2768.1030403@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Chris J Arges <chris.j.arges@canonical.com>, shemminger@osdl.org,
	ebiederm@xmission.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:16999 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756660Ab3KIRAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 12:00:39 -0500
In-Reply-To: <527D2768.1030403@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2013 02:03 AM, Chris J Arges wrote:
> Hi,
> The commit
> https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/commit/?id=58a3e8270fe72f8ed92687d3a3132c2a708582dd
> could be potentially introducing a regression on an upgrade.
>
> I've noticed that upgrading iproute while there are active namespaces
> could cause the following error:
> seting the network namespace failed: Invalid argument
>
> Here's a test case:
> Build and install iproute2 with 4395d48c78a77a99c5a8618403211032356fe552
>
> In one terminal run:
> ip netns add netns_old
> ip link add name if_old type veth peer name if_old_peer
> ip link set dev if_old_peer netns netns_old
> ip netns exec netns_old bash
>
> Build and install iproute2 with yypyye72f8ed92687d3a3132c2a708582dd
>
> In the same terminal as you typed the original commands run:
> ip netns add netns_one
> ip link add name if_one type veth peer name if_one_peer
> ip link set dev if_one_peer netns netns_one
> ip netns exec netns_one bash
> ip netns exec netns_old bash
>
> You'll get:
> seting the network namespace failed: Invalid argument
>
> If you just run the above without transitioning to the code in 58a3e827,
> then it works.

I've seen this error recently as well, and when it does happen if you go 
look in /var/run/netns you'll see that the permissions on your 
namespace(s) are most likely 000.  The only solution I found was to 
reboot, and then only use the newer iproute.

Maybe that info can help track down the cause?

-Brian
