From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Wed, 17 Sep 2008 12:50:53 -0700
Message-ID: <20080917125053.1f9ecf37.akpm@linux-foundation.org>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	<SpS7rta8n4.A.i9G.ZcsyIB@albercik>
	<alpine.LRH.1.10.0809130812460.12313@tundra.namei.org>
	<20080912152443.c4e59f42.akpm@linux-foundation.org>
	<alpine.LRH.1.10.0809131012310.13073@tundra.namei.org>
	<20080913123722.e238ae2a.akpm@linux-foundation.org>
	<1221483926.30816.18.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1221483926.30816.18.camel-/ugcdrsPCSfIm9DtXLC9OUVfdvkotuLY+aIohriVLy8@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Sep 2008 09:05:26 -0400
Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org> wrote:

> 
> On Sat, 2008-09-13 at 12:37 -0700, Andrew Morton wrote:
> > On Sat, 13 Sep 2008 10:15:43 +1000 (EST) James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org> wrote:
> > 
> > > On Fri, 12 Sep 2008, Andrew Morton wrote:
> > > 
> > > > > > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11500
> > > > > > Subject		: /proc/net bug related to selinux
> > > > > > Submitter	: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> > > > > > Date		: 2008-09-04 17:45 (9 days old)
> > > > > > References	: http://marc.info/?l=linux-kernel&m=122055041313270&w=4
> > > > > 
> > > > > I think this might be a regression caused by namespace changes which we 
> > > 
> > > By which I mean, this was caused by a non-SELinux change to the upstream 
> > > kernel many, many eons ago.
> > 
> > hm, seems that 2.6.24 is OK but 2.6.25 is not.  I must have missed the
> > bug when testing 2.6.25-based kernels.
> > 
> > I started a git bisection search but after half an hour I hit bad
> > bisection breakage: a complete machine hang in fib_rules_init().
> > 
> > > > > addressed in SELinux policy.  Which distro version & policy version is 
> > > > > this seen with?
> > > > > 
> > > > 
> > > > FC5 on x86_32 and FC6 on x86_64.
> > > 
> > > As mentioned in the bugzilla, any related avc messages would be useful.
> > 
> > 2.6.25 dmesg: http://userweb.kernel.org/~akpm/dmesg-sony.txt
> > /var/log/messages: http://userweb.kernel.org/~akpm/messages-sony.txt
> > 
> > The latter includes this:
> > 
> > Sep 13 12:32:43 sony kernel: SELinux:  class key not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  class dccp_socket not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  class memprotect not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  class peer not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  class capability2 not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission open in class dir not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission open in class file not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission open in class chr_file not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission open in class blk_file not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission open in class fifo_file not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission dccp_recv in class node not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission dccp_send in class node not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission recvfrom in class node not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission sendto in class node not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission dccp_recv in class netif not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission dccp_send in class netif not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission ingress in class netif not defined in policy
> > Sep 13 12:32:43 sony kernel: SELinux:  permission egress in class netif not defined in policy
> > Sep 13 12:32:44 sony kernel: SELinux:  permission setkeycreate in class process not defined in policy
> > Sep 13 12:32:44 sony kernel: SELinux:  permission setsockcreate in class process not defined in policy
> > Sep 13 12:32:44 sony kernel: SELinux:  permission setfcap in class capability not defined in policy
> > Sep 13 12:32:44 sony kernel: SELinux:  permission polmatch in class association not defined in policy
> > Sep 13 12:32:44 sony kernel: SELinux:  permission flow_in in class packet not defined in policy
> > Sep 13 12:32:44 sony kernel: SELinux:  permission flow_out in class packet not defined in policy
> > Sep 13 12:32:44 sony kernel: SELinux:  permission forward_in in class packet not defined in policy
> > Sep 13 12:32:44 sony kernel: SELinux:  permission forward_out in class packet not defined in policy
> > Sep 13 12:32:44 sony kernel: SELinux: the above unknown classes and permissions will be denied
> > Sep 13 12:32:44 sony kernel: type=1403 audit(1221309118.644:3): policy loaded auid=4294967295 ses=4294967295
> > Sep 13 12:32:44 sony kernel: type=1400 audit(1221334321.726:4): avc:  denied  { audit_write } for  pid=400 comm="hwclock" capability=29 scontext=system_u:system_r:hwclock_t:s0 tcontext=system_u:system_r:hwclock_t:s0 tclass=capability
> > 
> > 
> > Why am I seeing this on two machines and two vanilla-installed distros
> > but nobody else is reporting it?

Running `ls -l /proc/net' on the FC6 machine produces:

[  132.591215] type=1400 audit(1221679672.590:10): avc:  denied  { getattr } for  pid=4389 comm="ls" path="/proc/net" dev=proc ino=4026531867 scontext=user_u:system_r:unconfined_t:s0 tcontext=system_u:object_r:proc_net_t:s0 tclass=lnk_file


> What we actually need to see is the output of:
> /sbin/ausearch -i -m AVC -sv no

akpm2:/home/akpm# /sbin/ausearch -i -m AVC -sv no 
<no matches>

> However, the most likely explanation is simply that when /proc/net was
> changed from being a directory to being a symlink to /proc/self/net,
> that introduced an additional permission check on accesses
> of /proc/net/<whatever>, namely the read check on the symlink itself.
> And since that check wasn't happening on /proc/net accesses with older
> kernels, older policies didn't allow it.
> 
> As to why others haven't reported it, I expect that they have updated
> their policies to newer ones that allow the necessary access.  The fact
> that legacy distros wouldn't have such updated policies isn't surprising
> - they don't push updates to those distros for new kernels.  FC5 and FC6
> are both EOL'd, right?
> 
> In any event, we didn't change anything in SELinux - the change was
> elsewhere (in the proc/net implementation).  Don't blame the messenger
> please.
> 

Vanilla FC5 broke and vanilla FC6 broke.  Did vanilla FC7, 8 or 9 break?

http://smolt.fedoraproject.org/static/stats/stats.html shows 11,000-odd
people running FC5 and FC6.  It would be incautious to assume that all
those people have updated their selinux rules.

And _requiring_ people to update their selinux rules to fix a
kernel-caused regression is a pretty big deal for some people, I
expect.

Then again, given that this regression has been out there since 2.6.25,
I guess not too many people are hurting from it.  But we suck.
