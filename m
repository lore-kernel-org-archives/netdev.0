From: jamal <hadi@cyberus.ca>
Subject: Re: IMQ / new Dummy device post.
Date: 22 Apr 2004 09:16:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082639764.1059.81.camel@jzny.localdomain>
References: <wazza.87ad18jbdl.fsf@message.id>
	 <1082427350.1034.70.camel@jzny.localdomain>
	 <wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
	 <wazza.87hdvddqxq.fsf@message.id>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: syrius.ml@no-log.org
In-Reply-To: <wazza.87hdvddqxq.fsf@message.id>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,

On Wed, 2004-04-21 at 16:19, syrius.ml@no-log.org wrote:
> ok, i'm able to reproduce it with a simpler setup.
> 
> Let's consider I'm using the new dummy device on machine connected to
> a ethernet lan. this host is using openvpn to establish a vpn tunnel.

[..]

> after the ping -f 192.168.5.1 (let's say i let it run 30sec), if a do
> ping 172.16.0.1 the oops appears !
> 
> I attach the result of ksymoops.
> 
> Please tell me if you're able to reproduce it.
> I'm ok to try with another vpn software, but I don't think it has
> anything to do with openvpn.
> 

It may be more related to the tun device that software uses. Tun is an
interesting netdevice. I dont have a setup to reproduce this.

BTW, doesnt the packet eventually make it to eth0 coming from the vpn?
Also the other direction is true (always starts at the eth0 level); if
yes, why do you have to redirect packets from the tap device?

Try the following to debug:

remove the egress qdisc from the tap device and run the test.
(this part: $TC qdisc add dev tun0 root handle 1: prio)
If thats till ooopses, remove the ingress attachment to the tun.
And if that still fails, compile both tun and dummy into the kernel
(as opposed to modules) and reproduce the oops.
Additionaly some useful tools are stats on the dummy devices as well
as the actions (example:  tc -s filter ls dev eth0 parent ffff:)

cheers,
jamal

________________________________________________________________________
