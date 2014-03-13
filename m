From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 12:58:14 -0700
Message-ID: <CALCETrUj4aPEd6ujXnUJNFq+BQkfQoF=XRChP1p5=ZysTN-zwg@mail.gmail.com>
References: <5320CAEC.6030008@amacapital.net> <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
 <1394658983.32465.203.camel@willson.li.ssimo.org> <CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
 <1394673476.32465.215.camel@willson.li.ssimo.org> <CALCETrWbCuKfV4zMkZajDOGhGkKduW0C2L7uHv=vtvqhVeAc6w@mail.gmail.com>
 <1394675038.32465.223.camel@willson.li.ssimo.org> <CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw@mail.gmail.com>
 <1394733077.32465.243.camel@willson.li.ssimo.org> <CALCETrXWzja6W6y=p9MrtynGZMsrD5KQu0KBK6Bs1dQxnesv2A@mail.gmail.com>
 <20140313195349.GM18914@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Simo Sorce <ssorce@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	jkaluza@redhat.com, lpoetter@redhat.com, kay@redhat.com
To: Vivek Goyal <vgoyal@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f170.google.com ([209.85.220.170]:61872 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259AbaCMT6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:58:35 -0400
Received: by mail-vc0-f170.google.com with SMTP id hu19so1700784vcb.15
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 12:58:34 -0700 (PDT)
In-Reply-To: <20140313195349.GM18914@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2014 at 12:53 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Thu, Mar 13, 2014 at 10:55:16AM -0700, Andy Lutomirski wrote:
>
> [..]
>> >> 2. Docker is a container system, so use the "container" (aka
>> >> namespace) APIs.  There are probably several clever things that could
>> >> be done with /proc/<pid>/ns.
>> >
>> > pid is racy, if it weren't I would simply go straight
>> > to /proc/<pid>/cgroups ...
>>
>> How about:
>>
>> open("/proc/self/ns/ipc", O_RDONLY);
>> send the result over SCM_RIGHTS?
>
> As I don't know I will ask. So what will server now do with this file
> descriptor of client's ipc namespace.
>
> IOW, what information/identifier does it contain which can be
> used to map to pre-configrued per container/per namespace policies.

Inode number, which will match that assigned to the container at runtime.

(I'm not sure this is a great idea -- there's no convention that "I
have an fd for a namespace" means "I'm a daemon in that namespace".)

--Andy

>
> Thanks
> Vivek



-- 
Andy Lutomirski
AMA Capital Management, LLC
