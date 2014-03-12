From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Wed, 12 Mar 2014 14:19:54 -0700
Message-ID: <CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
 <1394657163-7472-3-git-send-email-vgoyal@redhat.com> <5320CAEC.6030008@amacapital.net>
 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com> <1394658983.32465.203.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394658983.32465.203.camel-Hs+ccMQdwurzDu64bZtGtWD2FQJk+8+b@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 2:16 PM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, 2014-03-12 at 14:12 -0700, Andy Lutomirski wrote:
>> On Wed, Mar 12, 2014 at 2:00 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> > On 03/12/2014 01:46 PM, Vivek Goyal wrote:
>> >> Implement SO_PEERCGROUP along the lines of SO_PEERCRED. This returns the
>> >> cgroup of first mounted hierarchy of the task. For the case of client,
>> >> it represents the cgroup of client at the time of opening the connection.
>> >> After that client cgroup might change.
>> >
>> > Even if people decide that sending cgroups over a unix socket is a good
>> > idea, this API has my NAK in the strongest possible sense, for whatever
>> > my NAK is worth.
>> >
>> > IMO SO_PEERCRED is a disaster.  Calling send(2) or write(2) should
>> > *never* imply the use of a credential.  A program should always have to
>> > *explicitly* request use of a credential.  What you want is SCM_CGROUP.
>> >
>> > (I've found privilege escalations before based on this observation, and
>> > I suspect I'll find them again.)
>> >
>> >
>> > Note that I think that you really want SCM_SOMETHING_ELSE and not
>> > SCM_CGROUP, but I don't know what the use case is yet.
>>
>> This might not be quite as awful as I thought.  At least you're
>> looking up the cgroup at connection time instead of at send time.
>>
>> OTOH, this is still racy -- the socket could easily outlive the cgroup
>> that created it.
>
> I think you do not understand how this whole problem space works.
>
> The problem is exactly the same as with SO_PEERCRED, so we are taking
> the same proven solution.

You mean the same proven crappy solution?

>
> Connection time is all we do and can care about.

You have not answered why.

>
> Simo.
>
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
