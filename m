From: jamal <hadi@cyberus.ca>
Subject: Re: RFC:  Redirect-Device
Date: 31 Mar 2005 16:53:51 -0500
Message-ID: <1112306031.1073.109.camel@jzny.localdomain>
References: <424C6089.1080507@candelatech.com>
	 <1112303627.1073.71.camel@jzny.localdomain>
	 <424C6B10.6030200@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C6B10.6030200@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 16:26, Ben Greear wrote:
> jamal wrote:
> > On Thu, 2005-03-31 at 15:41, Ben Greear wrote:
> 
> > I must be missing something: What is it that this device can do that the
> > mirred action cant do? 
> > Or in general the action framework on the ingress side?
> > We can redirect to any arbitrary device; we can mirror to any arbitray
> > device; we can drop, mangle packets identified via classification rules
> > in any arbitrary way etc
> 
> I can operate on these devices with normal socket calls from user-space, and
> can treat them as normal net_devices from kernel modules.  I do not have to
> parse or manage the mirrored action logic, and I know that I absolutely have
> total control over packets with my user-space language of choice.  (I am not
> sure how easy it is to use your classification rules and mangling operations
> in an arbitrary manner.)
> 

You can configure actions using sockets (netlink sockets).
Thats what tc does for example. As a matter of fact you already have a
"language" - its what tc is, sample BNF grammar of the language:

---
[root@jzny root]# tc
Usage: tc [ OPTIONS ] OBJECT { COMMAND | help }
where  OBJECT := { qdisc | class | filter }
       OPTIONS := { -s[tatistics] | -d[etails] | -r[aw] | -b[atch] file
}
---

You can write a little API on top of netlink that could ease the
intricacies of netlink. Thats what libnetlink in iproute2(that tc use)
and what Thomas is writting are attempting to do.

So - you have a lot of control ..

A few people have written "languages" to improve on tc. The most
prominent being Werner Almesbergers tcng http://tcng.sourceforge.net/

> I can also create a nice little set of virtual interfaces
> and connections  rdd0 <-> rdd1  |bridge|  rdd2 <-> rdd3.  I can then send traffic
> from rdd0 to rdd3 across the bridge, etc.  Now, this last bit is fairly
> contrived, but it happens to help me with some testing on my laptop which
> lacks a lot of external ethernet interfaces :)
> 

So your goal is to define a path that the packet takes inside the kernel
across multiple devices? i.e some form of loose source routing?

> To be honest, I didn't dig into the actions.  It would be much harder for
> me to manage things in that manner, whereas virtual interfaces just work
> for me.

Understood - just not empathized ;->

cheers,
jamal
