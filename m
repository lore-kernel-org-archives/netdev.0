From: "Alex Aizman" <itn780@yahoo.com>
Subject: RE: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Tue, 29 Mar 2005 18:28:25 -0800
Message-ID: <200503300228.j2U2Slul009687@oss.sgi.com>
References: <1112138018.1088.31.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'netdev'" <netdev@oss.sgi.com>, <ksummit-2005-discuss@thunk.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: <open-iscsi@googlegroups.com>, "'Rick Jones'" <rick.jones2@hp.com>
In-Reply-To: <1112138018.1088.31.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal wrote: 
> 
> > 
> > Eventually the TCP will hit its RTX limit and punt the connection, 
> > freeing the buffers kept for retransmission right?
> > 
> 
> If i read correctly the people arguing for iscsi say thats 
> not good enough. But they may be having other issues too...

It is not good enough for storage. 

If we continue to fall back into TCP-will-eventually-recover mentality
iSCSI, or at least a "soft" non-offloaded iSCSI over regular non-TOE TCP,
will not be able to compete with FC, which uses determinstic credit-based
flow control. That non-determinism is a bigger issue, while a corner case
like swap device happenning to be iSCSI-remote is just that, a corner case
that helps to highlight and bring the general problem to the foreground.

Adding a "critical" or "resource-protected" attribute to the connection
context is a step in the right  direction. Next steps include:

- triage (closing non-critical connections in OOM);
- socket reopen without deallocating memory (something like: close(int
socket_fd, int will_reopen));
- preallocated mempools (it is much better to discover OOM at connection
open time than well into runtime).
- better resource "counting" throughout the L3 and L4 layers to preventively
handle OOM;

And more incremental steps like that.

Alex
