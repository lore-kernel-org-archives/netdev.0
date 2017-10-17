From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Tue, 17 Oct 2017 07:59:43 -0700
Message-ID: <a07968f6-fef1-f49d-01f1-6c660c0ada20@schaufler-ca.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
 <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
 <20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
 <2319693.5l3M4ZINGd@x2> <1508243469.6230.24.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Richard Guy Briggs <rgb@redhat.com>, mszeredi@redhat.com,
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
To: Simo Sorce <simo@redhat.com>, Steve Grubb <sgrubb@redhat.com>,
        linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sonic307-17.consmr.mail.ne1.yahoo.com ([66.163.190.40]:35618
        "EHLO sonic307-17.consmr.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932708AbdJQO7v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 10:59:51 -0400
In-Reply-To: <1508243469.6230.24.camel@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 5:31 AM, Simo Sorce wrote:
> On Mon, 2017-10-16 at 21:42 -0400, Steve Grubb wrote:
>> On Monday, October 16, 2017 8:33:40 PM EDT Richard Guy Briggs wrote:
>>> There is such a thing, but the kernel doesn't know about it
>>> yet.  This same situation exists for loginuid and sessionid which
>>> are userspace concepts that the kernel tracks for the convenience
>>> of userspace.  As for its name, I'm not particularly picky, so if
>>> you don't like CAP_CONTAINER_* then I'm fine with
>>> CAP_AUDIT_CONTAINERID.  It really needs to be distinct from
>>> CAP_AUDIT_WRITE and CAP_AUDIT_CONTROL since we don't want to give
>>> the ability to set a containerID to any process that is able to do
>>> audit logging (such as vsftpd) and similarly we don't want to give
>>> the orchestrator the ability to control the setup of the audit
>>> daemon.
>> A long time ago, we were debating what should guard against rouge
>> processes from setting the loginuid. Casey argued that the ability to
>> set the loginuid means they have the ability to control the audit
>> trail. That means that it should be guarded by CAP_AUDIT_CONTROL. I
>> think the same logic applies today. 
> The difference is that with loginuid you needed to give processes able
> to audit also the ability to change it. You do not want to tie the
> ability to change container ids to the ability to audit. You want to be
> able to do audit stuff (within the container) without allowing it to
> change the container id.

Without a *kernel* policy on containerIDs you can't say what
security policy is being exempted. Without that you can't say what
capability is (or isn't) appropriate. You need a reason to have
a capability check that makes sense in the context of the kernel
security policy. Since we don't know what a container is in the
kernel, that's pretty hard. We don't create "fuzzy" capabilities
based on the trendy application behavior of the moment. If the
behavior is not related it audit, there's no reason for it, and
if it is, CAP_AUDIT_CONTROL works just fine. If this doesn't work
in your application security model I suggest that is where you
need to make changes.


> Of course if we made container id a write-once property maybe there is
> no need for controls at all, but I'm pretty sure there will be
> situations where write-once may not be usable in practice.
>
>> The ability to arbitrarily set a container ID means the process has
>> the ability to indirectly control the audit trail.
> The container Id can be used also for authorization purposes (by other
> processes on the host), not just audit, I think this is why a separate
> control has been proposed.
>
> Simo.
>
