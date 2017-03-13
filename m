From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next RFC v1 00/27] afnetns: new namespace type for
 separation on protocol level
Date: Mon, 13 Mar 2017 20:56:35 +0100
Message-ID: <CAHO5Pa1s949dohzEEE68Ux=mXA7N7sR-U98Jwjvx1a_A5AhFEw@mail.gmail.com>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
 <20170312.162613.1105038945335893886.davem@davemloft.net> <1489362279.2283.1.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489362279.2283.1.camel-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[CC += linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org]

Hannes,

Since this is a kernel-user-space API change, please CC linux-api@
(and on future iterations of the series). The kernel source file
Documentation/SubmitChecklist notes that all Linux kernel patches that
change userspace interfaces should be CCed to
linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, so that the various parties who are
interested in API changes are informed. For further information, see
https://www.kernel.org/doc/man-pages/linux-api-ml.html

Thanks,

Michael


On Mon, Mar 13, 2017 at 12:44 AM, Hannes Frederic Sowa
<hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org> wrote:
> Hi,
>
> On Sun, 2017-03-12 at 16:26 -0700, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
>> Date: Mon, 13 Mar 2017 00:01:24 +0100
>>
>> > afnetns behaves like ordinary namespaces: clone, unshare, setns syscalls
>> > can work with afnetns with one limitation: one cannot cross the realm
>> > of a network namespace while changing the afnetns compartement. To get
>> > into a new afnetns in a different net namespace, one must first change
>> > to the net namespace and afterwards switch to the desired afnetns.
>>
>> Please explain why this is useful, who wants this kind of facility,
>> and how it will be used.
>
> Yes, I have to enhance the cover letter:
>
> The work behind all this is to provide more dense container hosting.
> Right now we lose performance, because all packets need to be forwarded
> through either a bridge or must be routed until they reach the
> containers. For example, we can't make use of early demuxing for the
> incoming packets. We basically pass the networking stack twice for
> every packet.
>
> The usage is very much in line with how network namespaces are used
> nowadays:
>
> ip afnetns add afns-1
> ip address add 192.168.1.1/24 dev eth0 afnetns afns-1
> ip afnetns exec afns-1 /usr/sbin/httpd
>
> this spawns a shell where all child processes will only have access to
> the specific ip addresses, even though they do a wildcard bind. Source
> address selection will also use only the ip addresses available to the
> children.
>
> In some sense it has lots of characteristics like ipvlan, allowing a
> single MAC address to host lots of IP addresses which will end up in
> different namespaces. Unlink ipvlan however, it will also solve the
> problem around duplicate address detection and multiplexing packets to
> the IGMP or MLD state machines.
>
> The resource consumption in comparison with ordinary namespaces will be
> much lower. All in all, we will have far less networking subsystems to
> cross compared to normal netns solutions.
>
> Some more information also in the first patch, which adds a
> Documentation.
>
> Bye,
> Hannes
>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/
