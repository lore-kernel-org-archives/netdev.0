From: kashyapv <kashyapv@us.ibm.com>
Subject: Re: [PATCH] proportional share accept()
Date: Wed, 25 Feb 2004 14:31:00 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402251206280.3691-100000@dyn319495.beaverton.ibm.com>
References: <20040225120350.499bc573@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040225120350.499bc573@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004, Stephen Hemminger wrote:

> On Wed, 25 Feb 2004 11:04:13 -0800 (Pacific Standard Time)
> Vivek Kashyap <kashyapv@us.ibm.com> wrote:
> 
> > Stephen,
> > 
> > I've not understood your suggestion. How would you implement the solution?
> 
> I assume the goal is to provide some high level of resource control over network utilization
> in a system. The accept proposal is part of more general problem of how to virtualize
> the network infrastructure and services to provide different QoS based on a set of
> parameters.
> 
> Your assumption that server application is blind to all this. But the kind of applications

Not at all.  The  'seeing' application has it much easier if it can
set the prioritisation in the accept queue using this proposal.  Makes it
easier for the application to do what it does well rather than worry about
another feature  that rightfully needs to be a  service (in the kernel). 

The 'blind' applcation can be affected in the desired way 
without modification using the in-kernel solution. 


> that would need this resource control are already pretty smart (databases and web servers).
> So wouldn't you want the application to be involved.  Imagine a database;  wouldn't you want
> connections that come in with high priority to be scheduled in the database with high priority?

And that is what is being done quite efficiently as per the proposal. The
higher priority request is picked more favourably than the lower-priority 
requests in accordance with the proportion set.  The connections from 
addresses in range X can be classified as 'bronze' - 1, Y as silver - 2, 
and  Z as gold -3. The weights are assigned/modified per socket. 

Now if the application is 'smart' and knows what to do, it can use the 
socket option to set/reset its shares.  Alternatively, the admin keeps 
track of the traffic and response needs and accordingly tunes the proportions.
The in-kernel solution is quite generic -- the change is only to the 
accept logic.

In the case you suggest  it is per application. How does the application
become 'smart' is not clear. Mangling packets to queue to different
ip addresses, if that is how the solution will work, is not a good idea. 
Also, it is a lot better to solve it in place rather than in every application
that needs it.

Vivek
