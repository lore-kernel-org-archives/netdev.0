From: Andi Kleen <ak@suse.de>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: 03 Mar 2003 19:18:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <p73smu45n6o.fsf@amdsimf.suse.de>
References: <3E5E7081.6020704@nortelnetworks.com.suse.lists.linux.kernel> <20030228083009.Y53276@shell.cyberus.ca.suse.lists.linux.kernel> <3E5F748E.2080605@nortelnetworks.com.suse.lists.linux.kernel> <20030228212309.C57212@shell.cyberus.ca.suse.lists.linux.kernel> <3E619E97.8010508@nortelnetworks.com.suse.lists.linux.kernel> <20030302081916.S61365@shell.cyberus.ca.suse.lists.linux.kernel> <3E6398C4.2020605@nortelnetworks.com.suse.lists.linux.kernel>
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: Chris Friesen's message of "3 Mar 2003 19:07:27 +0100"
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Friesen <cfriesen@nortelnetworks.com> writes:

> I'll look at how they were measuring unix socket throughput and try 
> implementing something similar for UDP.  It's not clear to me how to 
> really measure throughput in a multicast environment though since it 
> depends very much on your application messaging patterns.

Unix sockets are often slower than TCP over loopback because they use
much smaller socket sizes by default. This causes much more context 
switches.

Just run a vmstat 1 in parallel and watch the context switch rates.

You can fix it by increasing the send and receive buffers of the unix
socket.

-Andi
