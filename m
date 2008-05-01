From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 00/10] sysfs tagged directories
Date: Wed, 30 Apr 2008 20:12:28 -0700
Message-ID: <20080501031228.GC4911@suse.de>
References: <20080429171015.473938697@theryb.frec.bull.fr> <20080429173621.GA16625@suse.de> <20080429180445.GA18110@sergelap.austin.ibm.com> <20080429184151.GA19794@suse.de> <20080429193417.GA19282@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759143AbYEADRT@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080429193417.GA19282@sergelap.austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2008 at 02:34:17PM -0500, Serge E. Hallyn wrote:
> Quoting Greg KH (gregkh@suse.de):
> > On Tue, Apr 29, 2008 at 01:04:45PM -0500, Serge E. Hallyn wrote:
> > > Quoting Greg KH (gregkh@suse.de):
> > > > On Tue, Apr 29, 2008 at 07:10:15PM +0200, Benjamin Thery wrote:
> > > > > Here is the announcement Eric wrote back in December to introduce his 
> > > > > patchset:
> > > > 
> > > > <snip>
> > > > 
> > > > Are the objections that Al Viro made to this patchset when it was last
> > > > sent out addressed in this new series?
> > > > 
> > > > thanks,
> > > > 
> > > > greg k-h
> > > 
> > > Which objections were those?  The last submission which I see by Eric
> > > was http://lkml.org/lkml/2007/12/1/15 this past December.  I see no
> > > response from Al and get the feeling you were ok with them.
> > > 
> > > So my hunch would be that Eric had addressed those before that last
> > > submission, but if not I'm sorry, and please do set me straight.
> > 
> > See the thread from Al starting with:
> > 	Date: Mon, 7 Jan 2008 10:24:17 +0000
> > 	From: Al Viro <viro@ZenIV.linux.org.uk>
> > 	To: "Eric W. Biederman" <ebiederm@xmission.com>
> > 	Cc: linux-kernel@vger.kernel.org, htejun@gmail.com,
> > 	        linux-fsdevel@vger.kernel.org, gregkh@suse.de
> > 	Subject: [RFC] netns / sysfs interaction
> > 	Message-ID: <20080107072301.GW27894@ZenIV.linux.org.uk>
> > 
> > He had a lot of questions and objections to this way forward, and I
> > share those objections.
> 
> Ah I see it, thanks.
> 
> All Al's questions appear to be about how a task migration will be handled
> in the face of funky userspace usage of sysfs files.  But it seems clear the
> first use of these will not be for migration but for vservers.  The key
> thing to remember is that we don't (as decided at kernel-summit 06) aim
> to hide from userspace the fact that it's in a vserver, we just give it
> what it needs so that it can pretend.
> 
> As we start implementing checkpoint and restart to effect migration,
> *clearly* if we're trying to restart a task which has cwd or an open fd
> in /sys/class/net/eth42/, but that directory doesn't exist on the target
> machine, then the restart (and hence migrate) fails.
> 
> There was a concern about
> /sys/devices/pci0000\:00/0000\:00\:0a.0/net:eth0.  Since that's a
> symlink to ../../../class/net/eth0, it will either point nowhere or
> point to the virtualized eth0, if veth1 (or vethN) was renamed to eth0
> in the container.  (see below)  If that is the wrong thing to do we
> could try to address it in this patchset, but I suspect it is better
> left until device namespace are implemented.  Does that sounds sane?

I really don't think so, but I'll wait for the reworked patches to
review them and see how badly they mess the code up :)

thanks,

greg k-h
