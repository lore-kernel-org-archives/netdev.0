From: Michael Guntsche <mike@it-loops.com>
Subject: [BUG] 3.0-rc1 Bridge not forwarding unicast packages
Date: Mon, 8 Aug 2011 19:42:19 +0200
Message-ID: <20110808192646@it-loops.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:57747
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752921Ab1HHRm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 13:42:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,

I just upgraded my router/bridge combo to 3.1-rc1 from 3.0 for
testing. On a first look everything seemed to work fine, but when I
tried to connect via openvpn to my internal network (tap0 being bridged
with the internal network) I noticed that I was not able to access the
server on my internal network. I could access the bridge (which is
acting as the openvpn server as well) just fine though. 
To debug this I ran tcpdump on the openvpn client and started a ping to the
internal network. I could see the ARP requests being answered.

19:23:49.247846 ARP, Request who-has 192.168.42.127 tell 192.168.42.96,
length 28
19:23:49.287752 ARP, Reply 192.168.42.127 is-at 00:13:d4:4f:a2:dc,
length 46

in this case .127 is the server on the internal net and .96 the openvpn
client, but the icmp request did not arrive on the server. 
The strange thing I noticed was that I could see broadcasts packages
from the server on the client

19:23:28.135185 IP 192.168.42.127.631 > 192.168.42.255.631: UDP, length
187
19:23:29.470975 IP 192.168.42.96.5353 > 224.0.0.251.5353: .......

but no icmp packages arrived on the server side.


brctl showmacs lan
port no mac addr                is local?       ageing timer
  1     00:0c:42:28:de:4e       yes                0.00
  2     00:0c:42:61:7f:f2       yes                0.00
  1     00:13:d4:4f:a2:dc       no                 0.00 <---- server on the lan side
  3     8e:22:41:d9:95:23       yes                0.00
  3     b6:e1:e3:06:c9:1a       no                 5.00 <---- client connected via tap0

Reverting to 3.0 solves the problem for me. I tried just reverting the bridge code on the server to the 3.0 version to make sure that it is really Bridge related, but there are too many changes outside the bridge tree so compilation fails for me.

If you need more information, please to not hesitate to conact me.

Kind regards,
Michael Guntsche
