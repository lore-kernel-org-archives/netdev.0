From: Boian Bonev <boian@bonev.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Thu, 10 Mar 2005 01:51:21 +0200
Message-ID: <20050309235122.7541.qmail@orange.bonev.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_1_1110412282_7539"
Content-Transfer-Encoding: 8bit
Cc: linux-net@vger.kernel.org
To: Jason Lunz <lunz@falooley.org>, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_1_1110412282_7539
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 7bit

> The question, though, is: *How* do you configure the nodes within the
> chassis such that the internal IPs (whatever they are) _stay_ internal,
> and any non-127/8 addressing can be used for the external interfaces?
> 
> I've done something similar, for example, using policy routing and the
> arp sysctls. Suppose you have a machine with 2 interfaces, and you want
> IP routing to happen on each of the two interfaces as independently as
> possible. My solution involves using the "iif" modifier in your routing
> rules ("ip rule" rules) to send packets to two completely different
> routing tables, and making sure arp doesn't bleed across the two
> interfaces. I don't know whether policy routing gives enough control to
> do this in a general fashion; i did it only for very specific types of
> traffic. But I suspect you could come up with something workable.

you can do that but you omit the interface addresses - suppose ext net is 10.20.10.1/24,
internal is 10.10.10.1/24, no matter what routing policies and rules you put, both interface
ips will be visible from both interfaces. now imagine you have another external net 10.30.10.1/24
and customer wants to route e.g. 10.10.0.0/16 from 10.20.10.1/24 via 10.30.10.5...
at least host 10.10.10.1 will not route but arrive locally to your blade host

btw. i have seen recently on iptables' patch-o-matic some module that could by condition route
traffic to local addresses to another host. anyway the whole thing is doable with any kind of 
addresses but just imagine what nightmare startup ruleset you will have on each box; then
modify your custom rules to conform that hell ruleset and... imho it will be much more easy to
create a custom transport over ethernet (in case your ext network could share addresses form
that protocol also) and forget about ipv4 for internal implementation. thus you'd have at least
better security between worlds ;-)

b.

--=_1_1110412282_7539--
