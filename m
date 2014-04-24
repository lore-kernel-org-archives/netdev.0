From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 24 Apr 2014 17:04:29 -0400
Message-ID: <20140424210429.GD19091@redhat.com>
References: <20140423164537.GD24651@redhat.com>
 <20140423.132955.671992126955940387.davem@davemloft.net>
 <20140424203427.GC19091@redhat.com>
 <20140424.164820.1543648508330465096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: luto@amacapital.net, tj@kernel.org, dwalsh@redhat.com,
	linux-kernel@vger.kernel.org, lpoetter@redhat.com,
	ssorce@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140424.164820.1543648508330465096.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 24, 2014 at 04:48:20PM -0400, David Miller wrote:
> From: Vivek Goyal <vgoyal@redhat.com>
> Date: Thu, 24 Apr 2014 16:34:27 -0400
> 
> > By open() time you mean at socket() time or at connect() time?
> 
> I mean at all of the places at which init_peercred() occurs.

init_peercred() is only used for stream sockets and not for datagram
sockets. Hence the confusion that what are cgroup semantics for datagram
sockets.

> 
> > You also mentioned that you want SO_PEERCGROUP and SO_PASSCGROUP as
> > pairs like SO_PEERCRED and SO_PASSCRED.  But to me, SO_PEERCRED and
> > SO_PASSCRED are not *exact* pairs and are little different in their
> > semantics.  SO_PEERCRED gives us client creds at connect() time
> > while SO_PASSCRED client's real creds at sendmsg() time. SO_PASSCRED
> > does not store client's credential's at connect() time for datagram
> > sockets.
> 
> Then you haven't been following the discussion.
> 
> The client's credentials at sendmsg()/write() time are "DO NOT CARE".
> 
> You cannot even guarentee the semantics in the logging example if
> you ask for these "client identity at sendmsg() time" semantics.
> 
> What if the event occured when the client was in cgroup1, and the
> log message goes out after it has been moved into cgroup2?

Does it really matter. If a task is changing cgroup while it is doing
other operations, I don't think one can guarantee which cgroup kernel
will effectively uses for a particular operation. It will depend on
what was cgroup when kernel actually made task_cgroup() call. 

> 
> That is just proof that this whole idea is fundamentally flawed.

I don't think anybody is looking for such strong semantics. For example,
same issue will exist if receiver gets the message and looks up
/proc/pid/cgroup to associate message with a cgroup. By then task might
have changed cgroup.

So I really don't think changing cgroup is a problem w.r.t API.

Thanks
Vivek
