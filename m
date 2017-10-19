From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Fri, 20 Oct 2017 10:11:33 +1100
Message-ID: <8f495870-dd6c-23b9-b82b-4228a441c729@suse.de>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
 <2307769.VGpzlLa4Dp@x2>
 <20171019195747.4ssujtaj3f5ipsoh@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171019195747.4ssujtaj3f5ipsoh-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
Content-Language: en-US
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>> The registration is a pseudo filesystem (proc, since PID tree already
>>> exists) write of a u8[16] UUID representing the container ID to a file
>>> representing a process that will become the first process in a new
>>> container.  This write might place restrictions on mount namespaces
>>> required to define a container, or at least careful checking of
>>> namespaces in the kernel to verify permissions of the orchestrator so it
>>> can't change its own container ID.  A bind mount of nsfs may be
>>> necessary in the container orchestrator's mntNS.
>>> Note: Use a 128-bit scalar rather than a string to make compares faster
>>> and simpler.
>>>
>>> Require a new CAP_CONTAINER_ADMIN to be able to carry out the
>>> registration.
>>
>> Wouldn't CAP_AUDIT_WRITE be sufficient? After all, this is for auditing.
> 
> No, because then any process with that capability (vsftpd) could change
> its own container ID.  This is discussed more in other parts of the
> thread...

Not if we make the container ID append-only (to support nesting), or 
write-once (the other idea thrown around). In that case, you can't move 
"out" from a particular container ID, you can only go "deeper". These 
semantics don't make sense for generic containers, but since the point 
of this facility is *specifically* for audit I imagine that not being 
able to move a process from a sub-container's ID is a benefit.

-- 
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
