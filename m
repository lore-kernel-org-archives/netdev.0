From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/3] Distributed storage. Mirror algo extension for automatic recovery.
Date: Thu, 18 Oct 2007 23:17:41 +0400
Message-ID: <20071018191741.GA848@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47682 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756833AbXJRTRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 15:17:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I'm pleased to announce sixth release of the distributed storage
subsystem, which allows to form a storage on top of remote and local
nodes, which in turn can be exported to another storage as a node to
form tree-like storages.

This release includes mirroring algorithm extension, which allows to
store 'age' of the given node on the underlying media.

In this case, if failed node gets new media, which does not contain 
correct 'age' (unique id assigned to the whole storage during 
initialization time), the whole node will be marked as dirty and
eventually resynced.

This allows to have completely transparent failure recovery - failed
node can be just turned off, its hardware fixed and then turned on. DST
core will detect connection reset and automatically reconnect when node
is ready and resync if needed without any special administrator's steps.

This patchset has been split into 4 parts:
0 - this introduction
1 - core files
2 - network state machine
3 - documentation and algorithms

Hope they all will find its way into mail lists.

Further TODO list includes:
* new redundancy algorithm (complex, low priority)
* some thoughts about distributed filesystem tightly connected to DST

Thank you.

Homepage:
http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

-- 
	Evgeniy Polyakov
