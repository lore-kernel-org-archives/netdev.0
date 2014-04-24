From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] net: Implement SO_PEERCGROUP and SO_PASSCGROUP
 socket options
Date: Thu, 24 Apr 2014 09:01:22 -0400
Message-ID: <20140424130122.GA19091@redhat.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
 <20140422.160558.627080587952506099.davem@davemloft.net>
 <CALCETrWHA5ZmzOHnz9LO+7v4byc8QiynGyjE_ju5sjokNqrjZA@mail.gmail.com>
 <20140422.162927.2182797573155988911.davem@davemloft.net>
 <CALCETrX_TCbKy-3W590wG3rq9O3Hzbqc_wu3EGg7PKn2NNsTpQ@mail.gmail.com>
 <20140423190532.GE22755@redhat.com>
 <5358284B.7020706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5358284B.7020706-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 23, 2014 at 04:53:31PM -0400, Daniel J Walsh wrote:
> 
> On 04/23/2014 03:05 PM, Vivek Goyal wrote:
> > On Tue, Apr 22, 2014 at 01:31:13PM -0700, Andy Lutomirski wrote:
> > [..]
> >>> Otherwise, without SO_PASSCGROUP, there is no way for datagram sockets
> >>> to find out the peer's open() time cgroup.
> >> Right.
> >>
> >> I'd still like to know what userspace applications want this feature.
> >> The canonical example seems to be journald, but journald doesn't use
> >> unix datagram sockets AFAICS,
> > Dan Walsh mentiond that systemd also monitors /dev/log (datagram socket) and
> > logs everything in journal. There this information should be useful.
> >
> > Thanks
> > Vivek
> I am fine with collecting only the information available at "open".  I
> can potentially see other Userspace Resource Constraints being built
> based on the Cgroup the process is in.  For example openshift wants to 
> limit the amount of email a process can send to only a few per second,
> which might be able to be controlled by a relay listening on a
> particular socket. Then it could change the rules based on the
> Cgroup/Unit file the calling process was in. 

I suspect that we will see the need of both the kind of cgroup
information. One which shows current cgroup of sender and other which
shows cgroup of client when socket was opened. 

For the time being I will modify my patch as Dave Miller suggested and
repost. May be down the line there will be another option say
SO_PASSCURRENTCGROUP which will carry current cgroup of sender.

Thanks
Vivek
