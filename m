From: jamal <hadi@cyberus.ca>
Subject: Re: PROBLEM: Interface address change netlink socket problem.(Patch
Date: Thu, 10 Oct 2002 08:03:18 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210100722400.16149-100000@shell.cyberus.ca>
References: <3DA500D7.8000704@ipinfusion.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vividh Siddha <vividh@ipinfusion.com>
In-Reply-To: <3DA500D7.8000704@ipinfusion.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 9 Oct 2002, Vividh Siddha wrote:

> Thats true but we are working around a problem which exists in the Linux
> stack. Ideally when we set only a interface address, the netmask should
> remain the same as it was before. Also the default netmasks based on
> classes might not be what is set. If we set netmask as /23, then:
>
> ifconfig eth0 10.10.10.50
>
> will cause the netmask to be /8. The end result of all of these is correct but the intermediate messages can cause problems in higher layer protocols.
>

calling it "a problem which exists on the linux stack" is pushing it ..
You pass three operations to ifconfig;
"change" ipaddr, "change" netmask, "change" broadcast.

1) There is no atomic "change" operator. It translates to "add" then
"delete" from userland.
2) You delete the IP address which as the primary piece of data resets
everything including netmask and broadcasts to defaults

There are 2 ways to formally and correctly do it:  introduce some
form of two-phase commit. You send all the commands to the kernel and then
send it a commit to tell it to make the changes. The other way to do it is
to introduce a change operator;
Both these two break BSD semantics. OTOH, you can do either by working
with netlink by  batching all three atomic operations and introducing some
new flags.

cheers,
jamal
