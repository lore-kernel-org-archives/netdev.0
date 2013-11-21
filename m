From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v3] packet: fix use after free race in send path when
 dev is released
Date: Thu, 21 Nov 2013 14:40:22 -0800
Message-ID: <528E8BD6.3060200@candelatech.com>
References: <1385049058-1946-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Salam Noureddine <noureddine@aristanetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57903 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044Ab3KUWkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 17:40:40 -0500
In-Reply-To: <1385049058-1946-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 07:50 AM, Daniel Borkmann wrote:
> Salam reported a use after free bug in PF_PACKET that occurs when
> we're sending out frames on a socket bound device and suddenly the
> net device is being unregistered. It appears that commit 827d9780
> introduced a possible race condition between {t,}packet_snd() and
> packet_notifier(). In the case of a bound socket, packet_notifier()
> can drop the last reference to the net_device and {t,}packet_snd()
> might end up suddenly sending a packet over a freed net_device.


Thank you all for finding and fixing this!

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
