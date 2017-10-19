From: Aleksa Sarai <asarai@suse.de>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Fri, 20 Oct 2017 10:15:25 +1100
Message-ID: <b0a59b79-64a5-feeb-7f85-ec0f482f0b96@suse.de>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
 <2307769.VGpzlLa4Dp@x2>
 <20171019195747.4ssujtaj3f5ipsoh@madcap2.tricolour.ca>
 <8f495870-dd6c-23b9-b82b-4228a441c729@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: cgroups@vger.kernel.org, mszeredi@redhat.com,
        David Howells <dhowells@redhat.com>,
        Simo Sorce <simo@redhat.com>, jlayton@redhat.com,
        Carlos O'Donell <carlos@redhat.com>,
        Linux API <linux-api@vger.kernel.org>,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Paul Moore <pmoore@redhat.com>,
        Linux Audit <linux-audit@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andy Lutomirski <luto@kernel.org>,
        Eric Paris <eparis@parisplace.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        trondmy@primarydata.com,
        Linux Network Development <netdev@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
To: Richard Guy Briggs <rgb@redhat.com>,
        Steve Grubb <sgrubb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8f495870-dd6c-23b9-b82b-4228a441c729@suse.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>> The registration is a pseudo filesystem (proc, since PID tree already
>>>> exists) write of a u8[16] UUID representing the container ID to a file
>>>> representing a process that will become the first process in a new
>>>> container.  This write might place restrictions on mount namespaces
>>>> required to define a container, or at least careful checking of
>>>> namespaces in the kernel to verify permissions of the orchestrator 
>>>> so it
>>>> can't change its own container ID.  A bind mount of nsfs may be
>>>> necessary in the container orchestrator's mntNS.
>>>> Note: Use a 128-bit scalar rather than a string to make compares faster
>>>> and simpler.
>>>>
>>>> Require a new CAP_CONTAINER_ADMIN to be able to carry out the
>>>> registration.
>>>
>>> Wouldn't CAP_AUDIT_WRITE be sufficient? After all, this is for auditing.
>>
>> No, because then any process with that capability (vsftpd) could change
>> its own container ID.  This is discussed more in other parts of the
>> thread...
> 
> Not if we make the container ID append-only (to support nesting), or 
> write-once (the other idea thrown around). In that case, you can't move 
> "out" from a particular container ID, you can only go "deeper". These 
> semantics don't make sense for generic containers, but since the point 
> of this facility is *specifically* for audit I imagine that not being 
> able to move a process from a sub-container's ID is a benefit.

[This assumes it's CAP_AUDIT_CONTROL which is what we are discussing in 
a sister thread.]

-- 
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
