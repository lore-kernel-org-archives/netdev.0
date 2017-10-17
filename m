From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Tue, 17 Oct 2017 13:15:00 -0400
Message-ID: <1982291.vr6V9CPzqu@x2>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca> <1508255091.3129.27.camel@HansenPartnership.com> <eb96144d-4ab5-7f9f-de18-b296db35a00a@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>,
        Simo Sorce <simo@redhat.com>, linux-audit@redhat.com,
        mszeredi@redhat.com, trondmy@primarydata.com, jlayton@redhat.com,
        Linux API <linux-api@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>,
        Carlos O'Donell <carlos@redhat.com>, cgroups@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Andy Lutomirski <luto@kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Eric Paris <eparis@parisplace.org>,
        Al Viro <viro@zeniv.linux.org.uk>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <eb96144d-4ab5-7f9f-de18-b296db35a00a@schaufler-ca.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, October 17, 2017 12:43:18 PM EDT Casey Schaufler wrote:
> > The idea is that processes spawned into a container would be labelled
> > by the container orchestration system.  It's unclear what should happen
> > to processes using nsenter after the fact, but policy for that should
> > be up to the orchestration system.
> 
> I'm fine with that. The user space policy can be anything y'all like.

I think there should be a login event.


> > The label will be used as a tag for audit information.
> 
> Deep breath ...
> 
> Which *is* a kernel security policy mechanism. Since the "label"
> is part of the audit information that the kernel is guaranteeing
> changing it would be covered by CAP_AUDIT_CONTROL. If the kernel
> does not use the "label" for any other purpose this is the only
> capability that makes sense for it.

I agree. The ability to set the container label grants the ability to evade 
rules or modify audit rules. CAP_AUDIT_CONTROL makes sense to me.


> > I think you were missing label inheritance above.
> > 
> > The security implications are that anything that can change the label
> > could also hide itself and its doings from the audit system and thus
> > would be used as a means to evade detection.

Yes. We have the same problem with loginuid. There are restrictions on who can 
change it once set. And then we made an immutable flag so that people that 
want a hard guarantee can get that.

-Steve
