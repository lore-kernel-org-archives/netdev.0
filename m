From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage. Security attributes and ducumentation update.
Date: Sat, 22 Sep 2007 15:31:30 +0400
Message-ID: <20070922113130.GA24473@2ka.mipt.ru>
References: <20070831160611.GA21660@2ka.mipt.ru> <20070917182229.GA5966@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42577 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbXIVLcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2007 07:32:08 -0400
Content-Disposition: inline
In-Reply-To: <20070917182229.GA5966@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel.

On Mon, Sep 17, 2007 at 06:22:30PM +0000, Pavel Machek (pavel@ucw.cz) wrote:
> > I'm pleased to announce third release of the distributed storage
> > subsystem, which allows to form a storage on top of remote and local
> > nodes, which in turn can be exported to another storage as a node to
> > form tree-like storages.
> 
> How is this different from raid0/1 over nbd? Or raid0/1 over
> ata-over-ethernet?

I will repeate a quote I made for previous release:

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
	requires device mapper, is synchronous and wants
	special userspace thread)

DST allows to remove any nodes and then turn it
back into the storage without
breaking the dataflow, dst core will
reconnect automatically to the
failed remote nodes, it allows to work
with detouched devices just like
with usual filesystems (in case it was
not formed as a part of linear
storage, since in that case meta
information is spreaded between nodes).

It does not require special processes on
behalf of network connection,
everything will be performed
automatically on behalf of DST core
workers, it allows to export new device,
created on top of mirror or
linear combination of the others, which
in turn can be formed on top of
another and so on...

This was designed to allow to create a
distributed storage with
completely transparent failover
recovery, with ability to detouch remote
nodes from mirror array to became
standalone realtime backups (or
snapshots) and turn it back into the
storage without stopping main
device node. 

> > +|---------------- DST storate -------------------|
> 
> storage?

Yep, thanks.

-- 
	Evgeniy Polyakov
