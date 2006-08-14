From: Alexey Toptygin <alexeyt@freeshell.org>
Subject: Re: sysfs vs. d80211 configuration
Date: Mon, 14 Aug 2006 23:05:15 +0000 (UTC)
Message-ID: <Pine.NEB.4.64.0608142302560.21364@otaku.freeshell.org>
References: <44E07662.8070506@sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.freeshell.ORG ([192.94.73.18]:32487 "EHLO sdf.lonestar.org")
	by vger.kernel.org with ESMTP id S965043AbWHNXGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 19:06:33 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44E07662.8070506@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Aug 2006, Johannes Berg wrote:

> In my seemingly never-ending quest to actually use the d80211 stack for 
> something useful I just wanted to write a small setuid tool that:
> * creates and opens a new monitor interface
> * drops priviledges
> * ... does things with received frames ... (not interesting for this 
> discussion)
> * removes new monitor interface
>
> So I figured I'd just keep an fd open to 
> /sys/class/net/mymonitorinterface/remove_iface to which I could write the 
> interfaces name after I was done with it. However, when writing to that fd I 
> got -EACCESS because it checks for CAP_NET_ADMIN.

Why not have the tool create a monitor interface, open it, and fork; the 
child drops privileges and does the reading, and the parent wait(2)s for 
the child and removes the interface once it has collected the child?

 			Alexey
