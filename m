From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 10:27:55 -0400
Message-ID: <20140313142755.GC18914@redhat.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
 <1394657163-7472-3-git-send-email-vgoyal@redhat.com>
 <5320CAEC.6030008@amacapital.net>
 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
 <1394658983.32465.203.camel@willson.li.ssimo.org>
 <CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
 <1394673476.32465.215.camel@willson.li.ssimo.org>
 <CALCETrWbCuKfV4zMkZajDOGhGkKduW0C2L7uHv=vtvqhVeAc6w@mail.gmail.com>
 <1394675038.32465.223.camel@willson.li.ssimo.org>
 <CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simo Sorce <ssorce@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	jkaluza@redhat.com, lpoetter@redhat.com, kay@redhat.com
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 07:12:25PM -0700, Andy Lutomirski wrote:

[..]
> >> Can you give a realistic example?
> >>
> >> I could say that I'd like to disclose information to processes based
> >> on their rlimits at the time they connected, but I don't think that
> >> would carry much weight.
> >
> > We want to be able to show different user's list from SSSD based on the
> > docker container that is asking for it.
> >
> > This works by having libnsss_sss.so from the containerized application
> > connect to an SSSD daemon running on the host or in another container.
> >
> > The only way to distinguish between containers "from the outside" is to
> > lookup the cgroup of the requesting process. It has a unique container
> > ID, and can therefore be mapped to the appropriate policy that will let
> > us decide which 'user domain' to serve to the container.
> >
> 
> I can think of at least three other ways to do this.
> 
> 1. Fix Docker to use user namespaces and use the uid of the requesting
> process via SCM_CREDENTIALS.

Using user namespaces sounds like the right way to do it (atleast
conceptually). But I think hurdle here is that people are not convinced
yet that user namespaces are secure and work well. IOW, some people
don't seem to think that user namespaces are ready yet.

I guess that's the reason people are looking for other ways to
achieve their goal.

Thanks
Vivek
