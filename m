From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Wed, 18 Oct 2017 19:43:25 -0500
Message-ID: <871sm0j7bm.fsf@xmission.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
        <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
        <20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
        <2319693.5l3M4ZINGd@x2> <1508243469.6230.24.camel@redhat.com>
        <a07968f6-fef1-f49d-01f1-6c660c0ada20@schaufler-ca.com>
        <1508254120.6230.34.camel@redhat.com>
        <1508255091.3129.27.camel@HansenPartnership.com>
        <CAHC9VhRV9m6-APj3ofMQc22rL-WUoDzB8-urUxryszjCHHHLTg@mail.gmail.com>
        <49752b6f-8a77-d1e5-8acb-5a1eed0a992c@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
        cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>,
        Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49752b6f-8a77-d1e5-8acb-5a1eed0a992c-l3A5Bk7waGM@public.gmane.org> (Aleksa Sarai's
        message of "Thu, 19 Oct 2017 10:46:18 +1100")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> writes:

>>> The security implications are that anything that can change the label
>>> could also hide itself and its doings from the audit system and thus
>>> would be used as a means to evade detection.  I actually think this
>>> means the label should be write once (once you've set it, you can't
>>> change it) ...
>>
>> Richard and I have talked about a write once approach, but the
>> thinking was that you may want to allow a nested container
>> orchestrator (Why? I don't know, but people always want to do the
>> craziest things.) and a write-once policy makes that impossible.  If
>> we punt on the nested orchestrator, I believe we can seriously think
>> about a write-once policy to simplify things.
>
> Nested containers are a very widely used use-case (see LXC system containers,
> inside of which people run other container runtimes). So I would definitely
> consider it something that "needs to be supported in some way". While the LXC
> guys might be a *tad* crazy, the use-case isn't. :P

Of course some of that gets to running auditd inside a container which
we don't have yet either.

So I think to start it is perfectly fine to figure out the non-nested
case first and what makes sense there.  Then to sort out the nested
container case.

The solution might be that a process gets at most one id per ``audit
namespace''.

Eric
