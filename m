From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Tue, 29 Mar 2005 14:03:55 -0800
Message-ID: <4249D0CB.2030506@hp.com>
References: <424346FE.20704@cs.wisc.edu>	<20050324233921.GZ14202@opteron.random>	<20050325034341.GV32638@waste.org>	<20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org>	<1111905181.4753.15.camel@mylaptop>	<20050326224621.61f6d917.davem@davemloft.net>	<Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>	<m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>	<20050329152008.GD63268@muc.de>  <1112116762.5088.65.camel@beastie> <1112130512.1077.107.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
In-Reply-To: <1112130512.1077.107.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> I didnt quiet follow the discussion - Let me see if i can phrase the
> problem correctly (Trying to speak in general terms):
> 
> Sender is holding onto memory (retransmit queue i assume) waiting
> for ACKs. Said sender is under OOM and therefore drops ACKs coming in
> and as a result cant let go of these precious resource sitting on the
> retransmit queue. 
> And iscsi cant wait long enough for someone else to release memory so
> the ACKs can be delivered. 
> Did i capture this correctly?
> 
> If yes, the solution maybe to just drop all non-high-prio packets coming
> in during the denial of service attack (for lack of better term). In
> other words some strict prioritization scheduling (or rate control) at
> the network level either in the NIC or ingress qdisc level.

Eventually the TCP will hit its RTX limit and punt the connection, freeing the 
buffers kept for retransmission right?

> 
> On a slightly related topic: is SCSI (not iscsi) considered a reliable
> protocol?
> If yes, why would you wanna run a reliable protocol inside another
> reliable protocol (TCP)?

Isn't it better to consider TCP a protocol that provides reliable notice of 
(presumed) failure rather than a "reliable protocol?"

rick jones
