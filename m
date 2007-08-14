From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage. Mirroring to any number of devices.
Date: Tue, 14 Aug 2007 21:40:03 +0400
Message-ID: <20070814174003.GA31716@2ka.mipt.ru>
References: <20070814162918.GA30330@2ka.mipt.ru> <Pine.LNX.4.64.0708141919230.10912@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60352 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762947AbXHNRkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 13:40:09 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708141919230.10912@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 07:20:49PM +0200, Jan Engelhardt (jengelh@computergmbh.de) wrote:
> >I'm pleased to announce second release of the distributed storage
> >subsystem, which allows to form a storage on top of remote and local
> >nodes, which in turn can be exported to another storage as a node to
> >form tree-like storages.
> 
> I'll be quick: what is it good for, are there any users, and what could
> it have to do with DRBD and all the other distribution storage talk
> that has come up lately (namely NBD w/Raid1)?

It has number of advantages, outlined in the first release and on the
project homepage, namely:
* non-blocking processing without busy loops (compared to iSCSI and NBD)
* small, plugable architecture
* failover recovery (reconnect to remote target)
* autoconfiguration
* no additional allocatins (not including network  part) - at least two 
	in device mapper for fast path
* very simple - try to compare with iSCSI
* works with different network protocols
* storage can be formed on top of remote nodes and be exported 
	simultaneously (iSCSI is peer-to-peer only, NBD
	requires device mapper, is synchronous and wants special
	userspace thread)

Compared to DRBD, which is a mirroring of the local requests to remote
node, and raid on top of NBD, DST supports multiple remote nodes, it allows 
to remove any of them and then turn it back into the storage without
breaking the dataflow, dst core will reconnect automatically to the
failed remote nodes, it allows to work with detouched devices just like 
with usual filesystems (in case it was not formed as a part of linear 
storage, since in that case meta information is spreaded between nodes).
It does not require special processes on behalf of network connection,
everything will be performed automatically on behalf of DST core
workers, it allows to export new device, created on top of mirror or
linear combination of the others, which in turn can be formed on top of
another and so on...

This was designed to allow to create a distributed storage with
completely transparent failover recovery, with ability to detouch remote
nodes from mirror array to became standalone realtime backups (or
snapshots) and turn it back into the storage without stopping main 
device node.

-- 
	Evgeniy Polyakov
