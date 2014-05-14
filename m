From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multitude of dst obsolescense race conditions
Date: Wed, 14 May 2014 06:35:23 -0700
Message-ID: <1400074523.15916.117311749.3590532D@webmail.messagingengine.com>
References: <alpine.DEB.2.02.1405140233210.16893@dtop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: dormando <dormando@rydia.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:34306 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755751AbaENNfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 09:35:25 -0400
In-Reply-To: <alpine.DEB.2.02.1405140233210.16893@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014, at 2:57, dormando wrote:
> Given a machine with frequently changing routes (ie; a router with an
> active internet BGP table and multiple interfaces), there're at least
> several places where obsolete dst's are handled improperly. If I pause
> the
> route changes, the crashes appear to stop. This first one has a crash
> utility we've made, so I was able to more quickly find a patch and test
> it. The others take time to reproduce.
> 
> I'm testing against 3.10.39, but I think if these were fixed they'd be
> backported to stable? I've also had recent 3.12's running that have
> crashed in the same spots. Anyway correct me if I'm wrong...

Just a hunch:
You use macvlan? Could you somehow try without?
Maybe... some ref overflow? (You could add some testing code in dst_hold
with atomic_inc_return and WARN_ON).

dst_release already contains such a check, so I am not sure at all if
that could happen.

Bye,

  Hannes
