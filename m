From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Fun with if_bridge.h and br_private.h
Date: Mon, 3 May 2010 23:02:21 +0200
Message-ID: <201005032302.21860.arnd@arndb.de>
References: <20100503191256.GA18110@linux.vnet.ibm.com> <20100503133613.0f2a61f7@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:50773 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988Ab0ECVCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 17:02:30 -0400
In-Reply-To: <20100503133613.0f2a61f7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 03 May 2010 22:36:13 Stephen Hemminger wrote:
> > In file included from net/core/dev.c:104:
> > include/linux/if_bridge.h:106: warning: "struct net_bridge_port" declared inside parameter list
> > include/linux/if_bridge.h:106: warning: its scope is only this definition or declaration, which is probably not what you want
> > net/core/dev.c:2331: error: conflicting types for "br_handle_frame_hook"
> > include/linux/if_bridge.h:105: error: previous declaration of "br_handle_frame_hook" was here
> > net/core/dev.c:2333: error: conflicting types for "br_handle_frame_hook"
> > include/linux/if_bridge.h:105: error: previous declaration of "br_handle_frame_hook" was here
> > 
> > This happens because net/bridge/br_private.h includes if_bridge.h before
> > it defines net_bridge_port.
> > 
> > Any thoughts on how best to allow handle_bridge() see the definition
> > of struct net_bridge_port?
> > 
> 
> Why not make it a void *, there is no reason to make core code depend
> on br_private.h.

Ah, right. That's actually how I changed the definition of br_port to
start with. Sorry Paul, I had totally forgotten about this.
Not sure if we also need to change the br_handle_frame_hook prototype,
I think the forward declaration for struct net_bridge_port that I had
in my long patch was actually sufficient.

	Arnd
