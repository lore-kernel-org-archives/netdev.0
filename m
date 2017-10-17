From: Simo Sorce <simo@redhat.com>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Tue, 17 Oct 2017 08:31:09 -0400
Message-ID: <1508243469.6230.24.camel@redhat.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
         <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
         <20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
         <2319693.5l3M4ZINGd@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Richard Guy Briggs <rgb@redhat.com>,
        Casey Schaufler <casey@schaufler-ca.com>, mszeredi@redhat.com,
        "Eric W. Biederman" <ebiederm@xmission.com>, jlayton@redhat.com,
        Carlos O'Donell <carlos@redhat.com>,
        Linux API <linux-api@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Eric Paris <eparis@parisplace.org>,
        David Howells <dhowells@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andy Lutomirski <luto@kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        cgroups@vger.kernel.org, "Serge E. Hallyn" <serge@hallyn.com>,
        trondmy@primarydata.com
To: Steve Grubb <sgrubb@redhat.com>, linux-audit@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2319693.5l3M4ZINGd@x2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-10-16 at 21:42 -0400, Steve Grubb wrote:
> On Monday, October 16, 2017 8:33:40 PM EDT Richard Guy Briggs wrote:

> > There is such a thing, but the kernel doesn't know about it
> > yet.  This same situation exists for loginuid and sessionid which
> > are userspace concepts that the kernel tracks for the convenience
> > of userspace.  As for its name, I'm not particularly picky, so if
> > you don't like CAP_CONTAINER_* then I'm fine with
> > CAP_AUDIT_CONTAINERID.  It really needs to be distinct from
> > CAP_AUDIT_WRITE and CAP_AUDIT_CONTROL since we don't want to give
> > the ability to set a containerID to any process that is able to do
> > audit logging (such as vsftpd) and similarly we don't want to give
> > the orchestrator the ability to control the setup of the audit
> > daemon.
> 
> A long time ago, we were debating what should guard against rouge
> processes from setting the loginuid. Casey argued that the ability to
> set the loginuid means they have the ability to control the audit
> trail. That means that it should be guarded by CAP_AUDIT_CONTROL. I
> think the same logic applies today. 

The difference is that with loginuid you needed to give processes able
to audit also the ability to change it. You do not want to tie the
ability to change container ids to the ability to audit. You want to be
able to do audit stuff (within the container) without allowing it to
change the container id.
Of course if we made container id a write-once property maybe there is
no need for controls at all, but I'm pretty sure there will be
situations where write-once may not be usable in practice.

> The ability to arbitrarily set a container ID means the process has
> the ability to indirectly control the audit trail.

The container Id can be used also for authorization purposes (by other
processes on the host), not just audit, I think this is why a separate
control has been proposed.

Simo.

-- 
Simo Sorce
Sr. Principal Software Engineer
Red Hat, Inc
