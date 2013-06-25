From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v5 0/6] vxlan: allow specifying multiple
 default destinations
Date: Tue, 25 Jun 2013 14:19:23 -0700
Message-ID: <20130625141923.5aafd5a4@nehalam.linuxnetplumber.net>
References: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:51199 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab3FYVT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 17:19:27 -0400
Received: by mail-pa0-f67.google.com with SMTP id bj3so6945727pad.10
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 14:19:27 -0700 (PDT)
In-Reply-To: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Jun 2013 16:01:50 +0300
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> These patches add ability to specify multiple default destinations to
> vxlan. This ability is usefull in cases when multicast are disabled on
> infrastructure level, for instance in public clouds.
> 
> The default destinations list is managed via the fdb entry with
> "00:00:00:00:00:00" MAC address and does not require changes to vxlan
> netlink API.
> 
> The default destinations can be added/deleted using 'bridge fdb'
> commands, e.g:
> 
> # ip link add vxlan0 type vxlan id 23 group 239.1.1.1 dev eth0
> # bridge fdb show dev vxlan0
> 00:00:00:00:00:00 dst 239.1.1.1 self permanent
> 
> # bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst 54.242.49.246
> # bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst 23.22.26.34
> # bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst 184.72.129.120
> # bridge fdb show dev vxlan0
> 00:00:00:00:00:00 dst 239.1.1.1 self permanent
> 00:00:00:00:00:00 dst 54.242.49.246 self permanent
> 00:00:00:00:00:00 dst 23.22.26.34 self permanent
> 00:00:00:00:00:00 dst 184.72.129.120 self permanent
> 
> # bridge fdb delete 00:00:00:00:00:00 dev vxlan0 dst 23.22.26.34
> # bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst 54.242.49.246
> # bridge fdb show dev vxlan0
> 00:00:00:00:00:00 dst 239.1.1.1 self permanent
> 00:00:00:00:00:00 dst 184.72.129.120 self permanent
> 
> Since v5 is complete rework, I've dropped prevoius changelog as not relevant.
> 
I assume iproute changes are no longer needed?


It would be good to have multiple non-default destinations as well.
It would allow for implementing multicast MAC addresses.
