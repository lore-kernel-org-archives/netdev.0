From: kashyapv <kashyapv@us.ibm.com>
Subject: Re: [PATCH] proportional share accept()
Date: Wed, 25 Feb 2004 11:07:48 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402251017510.3691-100000@dyn319495.beaverton.ibm.com>
References: <20040225101225.496d02d0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040225101225.496d02d0.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It is a per socket scheduler not a global one. The control of the proportions
is with the socket/application. The sysctl can be removed - even then it only 
initialises the socket's proportions individually. The default is to use
only one queue.

A user space solution forces existing  applications to be modified. 
Additionally, it is not as efficient - If I understand the suggestion 
correctly the incoming request and data will have to be mangled both while 
coming in and going out if the client expects the reply from the same 
address it sent the conenction request to. 

Also, an in-kernel solution allows administrative control and tuning 
without affecting the applications at all. The administrator can as per 
the policy (which may change over time) modify the proportions using another
interface. Otherwise, each application must provide a way to manage/modify 
its scheduler.


Vivek


On Wed, 25 Feb 2004, David S. Miller wrote:

> On Wed, 25 Feb 2004 09:21:16 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > Just a cursory question, but would it be possible to just use iptables
> > to classify the packets and assign them to different IP addresses.
> > The the application could manage the priorities by opening two different
> > sockets (bound to different IP addresses) and do the scheduling there?
> 
> That's how I would attempt to implement this.  I really don't like this
> idea of putting a pseudo-classifier in the accept queue logic, and an
> ugly GLOBAL one at that, if anything it ought to be per-socket but even
> that I don't like.
> 
> 
> 
