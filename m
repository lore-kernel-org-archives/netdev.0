From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 4/4] net: Implement the per network namespace sysctl infrastructure
Date: Fri, 30 Nov 2007 14:49:25 -0700
Message-ID: <m13aun9zfe.fsf@ebiederm.dsl.xmission.com>
References: <4742C73C.3010904@openvz.org>
	<m1odddc5mf.fsf@ebiederm.dsl.xmission.com>
	<m1k5o1c5eh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fxypc5cd.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bq9dc53d.fsf_-_@ebiederm.dsl.xmission.com>
	<m17ik1c50m.fsf_-_@ebiederm.dsl.xmission.com>
	<20071130161856.GA10588@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46207 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbXK3Vv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 16:51:59 -0500
In-Reply-To: <20071130161856.GA10588@sergelap.austin.ibm.com> (Serge
	E. Hallyn's message of "Fri, 30 Nov 2007 10:18:56 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

>
> Hey Eric,
>
> the patches look nice.
>
> The hand-forcing of the passed-in net_ns into a copy of current->nsproxy
> does make it seem like nsproxy may not be the best choice of what to
> pass in.  Doesn't only net_sysctl_root->lookup() look at the argument?

Yes.  Although I call it from __register_sysctl_paths.

> But I assume you don't want to be more general than sending in a
> nsproxy so as to dissuade abuse of this interface for needlessly complex
> sysctl interfaces?

A bit of that.  I would love to pass in a task_struct so you can use
anything from a task.  The trouble is I don't have any task_structs or
nsproxys with the proper value at the point where I am first setting
this up.  Further I have to have the full sysctl lookup working or I
could not call sysctl_check.

> (Well I expect that'll become clear once the the patches using this
> come out.)
>
> Are you planning to use this infrastructure for the uts and ipc
> sysctls as well?

Yes.  Where it comes in especially useful, is I can move /proc/sys
to /proc/sys/<tgid>/task/<pid>/sys.  And get a particular processes
view of sysctl.  

We also get a little more reuse of common functions.

Otherwise Pavel does have a point that using this for uts and ipc
is not a savings lines of code wise.

After having seen Pavel changes I am asking myself if there is a sane
way to remove the ctl_name argument from the ctl_path.

Anyway where I am with the nsproxy question was that I don't
see anything easily better.  What I have works and gets the job
done, and doesn't have any module unload races or holes where a sloppy
programmer can mess up the sysctl tree.  We needed a solution.
Trying any harder to find something better would take ages.  So
I figured this implementation was good enough.

Eric
