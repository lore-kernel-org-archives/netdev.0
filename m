From: Bandan Das <bsd-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 0/4] Shared vhost design
Date: Sat, 01 Aug 2015 14:48:33 -0400
Message-ID: <jpgy4hukfpa.fsf@linux.bootlegged.copy>
References: <1436760455-5686-1-git-send-email-bsd@redhat.com>
	<OF451FED84.3040AFD2-ONC2257E8C.0043F908-C2257E8C.00446592@il.ibm.com>
	<jpgmvyh9ybg.fsf@linux.bootlegged.copy>
	<20150728000221-mutt-send-email-mst@redhat.com>
	<OFFB2CB583.341B00EF-ONC2257E94.002FF06E-C2257E94.0032BC0A@il.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Razya Ladelsky <RAZYA-7z/5BgaJwgfQT0dZR+AlfA@public.gmane.org>
To: Eyal Moscovici <EYALMO-7z/5BgaJwgfQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <OFFB2CB583.341B00EF-ONC2257E94.002FF06E-C2257E94.0032BC0A-7z/5BgaJwgfQT0dZR+AlfA@public.gmane.org>
	(Eyal Moscovici's message of "Sat, 1 Aug 2015 12:14:10 +0300")
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eyal Moscovici <EYALMO-7z/5BgaJwgfQT0dZR+AlfA@public.gmane.org> writes:
...
>
> We can start to implement polling, but I am unsure if the cgroups 
> integration 
> will be sufficient. The polling vhost thread should be scheduled all
> the time and just moving it from one cgroup to the other wont be 
> sufficient. 
> I think it needs a deeper integration to the point where either we have a 
> vhost thread for each cgroup or the vhost thread enforces the cgroup 
> policies over its polled VM guests.

Agreed, what we have with cgroups is not sufficient. I am waiting
for Tejun et al to comment on our approach :) Michael mentioned whether
it's possible to integrate cgroups into workgroups which I think is a more
generic and the preferred solution. I just don't know yet how easy/difficult
it is to implement this with the new cgroups unified hierarchy.


BTW, I am working on the numbers you had asked for. Honestly, I think the
cost of cgroups could be similar to running a vhost thread/guest since
that is how cgroups integration currently works. But it's good to have the
numbers before us. 

>> 
>> So simple polling by vhost is kind of ok for some guests, but I think to
>> really make it work for a reasonably wide selection of guests/workloads
>> you need to combine it with 1. polling the NIC - it makes no sense to me
>> to only poll one side of the equation; and probably 2. - polling in
>> guest.
>> 
>
> I agree that we need polling on the NIC which could probably be achieved 
> by using
> the polling interface introduced in kernel 3.11: 
> http://lwn.net/Articles/551284/
> although I never tried using it myself.
> About your point about polling inside the guest, I think it is orthogonal 
> to polling
> in the host.
>
>
> Eyal Moscovici
> HL-Cloud Infrastructure Solutions
> IBM Haifa Research Lab
