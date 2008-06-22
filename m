From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 00/25] Conntracking and NAT in netns
Date: Sun, 22 Jun 2008 04:59:16 +0400
Message-ID: <20080622005916.GA5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, patchbomb below makes significant parts of connection tracking and
NAT code usable in netns and independent from other netns.

Status is that it is lightly tested but more or less works, I used it on
a box which provides NAT for another with all netdevices moved to netns,
routing and iptables rules set up and rules flushed in init_net.

So far so good.

Weak points:
a) races during netns destruction or conntrack modules unload
   (see more in patches)
b) grabbing netns from skb->dev or skb->dst->dev
   these places should be checked with extreme scrunity :-\
c) some stuff not converted (pptp, h323) -- it's like 10 minutes to make
   a patch and full day to setup and test it :^)
d) IPv6 conntracking wasn't tested.
e) ordering probably should be redone (or it shouldn't since netfilter
   is banned in netns as is, so nobody will care)

