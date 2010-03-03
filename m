From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Wed, 3 Mar 2010 09:38:00 -0600
Message-ID: <20100303153800.GA937@us.ibm.com>
References: <4B894564.7080104@parallels.com>
 <m1iq9io5sc.fsf@fess.ebiederm.org>
 <4B89727C.9040602@parallels.com>
 <m1ljeempk6.fsf@fess.ebiederm.org>
 <4B8AE8C1.1030305@free.fr>
 <4B8D28CF.8060304@parallels.com>
 <20100302211942.GA17816@us.ibm.com>
 <m1y6iaqsmm.fsf@fess.ebiederm.org>
 <20100303000743.GA13744@us.ibm.com>
 <m1ocj6qljj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1ocj6qljj.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> writes:
> 
> > Eric W. Biederman [ebiederm@xmission.com] wrote:
> > | 
> > | I think replacing a struct pid for another struct pid allocated in
> > | descendant pid_namespace (but has all of the same struct upid values
> > | as the first struct pid) is a disastrous idea.  It destroys the
> >
> > True. Sorry, I did not mean we would need a new 'struct pid' for an
> > existing process. I think we talked earlier of finding a way of attaching
> > additional pid numbers to the same struct pid.
> 
> I just played with this and if you make the semantics of unshare(CLONE_NEWPID)
> to be that you become the idle task aka pid 0, and not the init task pid 1 the
> implementation is trivial.

Heh, and then (browsing through your copy_process() patch hunks) the next
forked task becomes the child reaper for the new pidns?  <shrug>  why not
I guess.

Now if that child reaper then gets killed, will the idle task get killed too?
And if not, then idle task can just re-populating the new pidns with new
idle tasks...

If this brought us a step closer to entering an existing pidns that would
be one thing, but is there actually any advantage to being able to
unshare a new pidns?  Oh, I guess there is - PAM can then use it at
login, which might be neat.

-serge
