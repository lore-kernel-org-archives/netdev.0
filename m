From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Fri, 14 Sep 2007 15:07:46 -0400
Message-ID: <46EADC02.9070409@garzik.org>
References: <20070914185429.GA9439@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758696AbXINTIH@vger.kernel.org>
In-Reply-To: <20070914185429.GA9439@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Hi.
> 
> I'm pleased to announce fourth release of the distributed storage
> subsystem, which allows to form a storage on top of remote and local
> nodes, which in turn can be exported to another storage as a node to
> form tree-like storages.
> 
> This release includes new configuration interface (kernel connector over
> netlink socket) and number of fixes of various bugs found during move 
> to it (in error path).
> 
> Further TODO list includes:
> * implement optional saving of mirroring/linear information on the remote
> 	nodes (simple)
> * new redundancy algorithm (complex)
> * some thoughts about distributed filesystem tightly connected to DST
> 	(far-far planes so far)
> 
> Homepage:
> http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

My thoughts.  But first a disclaimer:   Perhaps you will recall me as 
one of the people who really reads all your patches, and examines your 
code and proposals closely.  So, with that in mind...

I question the value of distributed block services (DBS), whether its 
your version or the others out there.  DBS are not very useful, because 
it still relies on a useful filesystem sitting on top of the DBS.  It 
devolves into one of two cases:  (1) multi-path much like today's SCSI, 
with distributed filesystem arbitrarion to ensure coherency, or (2) the 
filesystem running on top of the DBS is on a single host, and thus, a 
single point of failure (SPOF).

It is quite logical to extend the concepts of RAID across the network, 
but ultimately you are still bound by the inflexibility and simplicity 
of the block device.

In contrast, a distributed filesystem offers far more scalability, 
eliminates single points of failure, and offers more room for 
optimization and redundancy across the cluster.

A distributed filesystem is also much more complex, which is why 
distributed block devices are so appealing :)

With a redundant, distributed filesystem, you simply do not need any 
complexity at all at the block device level.  You don't even need RAID.

It is my hope that you will put your skills towards a distributed 
filesystem :)  Of the current solutions, GFS (currently in kernel) 
scales poorly, and NFS v4.1 is amazingly bloated and overly complex.

I've been waiting for years for a smart person to come along and write a 
POSIX-only distributed filesystem.

	Jeff
