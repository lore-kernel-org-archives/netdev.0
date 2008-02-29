From: serge@hallyn.com
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Fri, 29 Feb 2008 09:38:11 -0600
Message-ID: <20080229153811.GA5647@vino.hallyn.com>
References: <47C6D743.1050802@openvz.org> <m1y794514k.fsf@ebiederm.dsl.xmission.com> <20080228211720.GA1232@vino.hallyn.com> <m1k5ko4sfi.fsf@ebiederm.dsl.xmission.com> <20080229031737.GA3047@vino.hallyn.com> <47C7BF4D.6020202@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: serge@hallyn.com, "Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932320AbYB2PlU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47C7BF4D.6020202@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Pavel Emelyanov (xemul@openvz.org):
> [snip]
> 
> >> However at least for visibility and inspection we want that.
> >> We want to inspect what is happening to other processes.  If we didn't
> >> care then all of the pid namespaces could just be disjoint.
> > 
> > But the way Pavel has it coded, only tasks in the init namespace can
> > view /proc/.net/* for any other net namespaces.
> 
> This is not essential part of the patch :) I did so to make my
> life in init namespace easier. This part can be dropped.
> 
> [snip]
> 
> >> Think of user space processes inspecting /proc etc.
> > 
> > Well a task in one pid namespace cannot view the /proc for another pid
> > namespace, right?
> 
> No. Pid namespace provides another pid-to-task map, but have noting
> to do with VFS visibility.
> 
> >> Having directory
> >> names change out form under you for no apparent reason is pretty nasty.
> > 
> > Yes, but they won't just 'change out' from under you, you ask for it...
> > But here like I said I do prefer an approach where /proc/net is bind
> > mounted by the user.  But I have no good reason to back it up...
> 
> If you make /proc/net be a bund mount then you have to force all of
> the users to update their init scripts. I tried to make so with sysctl 
> filesystem, but this thread was not very popular :)

Ok.

A symlink is far preferable to sneaky redirection imo.

> Another way to do so - is to mount this one from inside the kernel, 
> but are you ready to fight with Al Viro for this? :)

Nope :)  Especially since it's an ugly idea.

> [snip]
> 
> >> So I think /proc/.netns/ or simply /proc/netns/ is a good choice. We
> >> just need a non-global id for our directory entries so we don't paint
> >> ourselves into a corner.
> > 
> > But I don't see how this is going to work.  If you're using a pid_nr
> > inside a pid namespace, then you're not guaranteeing that the pid_nr
> > will be unique, so you may not be able to create th e/proc/.netns/X
> > directory.  If you're using the global pid, then you're not guaranteeing
> > that it will be available upon a container restart.
> 
> Right - this is the same as using other ids, which I propose.
> 
> >> And honestly pid visibility is a very natural choice for which network
> >> namespaces you can see.  You can see the namespace of any process you
> >> can see.  Which especially means your children.  It is an arbitrary
> >> rule, it is a simple rule to explain, and it works recursively unlike
> > 
> > But apparently not simple enough for a simpleton like me to understand,
> > sorry :(
> > 
> >> any init_net is special rule.
> >>
> >> Eric

I suspect I'm misunderstanding Eric's proposal, though.

-serge
