From: jamal <hadi@cyberus.ca>
Subject: Re: PROBLEM: Interface address change netlink socket problem.(Patch
Date: Wed, 9 Oct 2002 22:46:47 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210092235300.16149-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vividh Siddha <vividh@ipinfusion.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Moved to netdev where it belongs. Vividh in the future please post
to netdev or at least cross-post to it ... because the kernel list
FAQ says so.

In your posting you say:
> Imagine a interface eth0 with address 10.10.10.10, netmask 0xffffff00
> and broadcast 10.10.10.255.
>
>For eg: if the following command is issued:
>ifconfig eth0 10.10.10.50 netmask 0xffffff00 broadcast 10.10.10.255
>
> The kernel sends the following three sets of messages on the netlink
>socket:
>
>Interface address delete: (with address 10.10.10.10)
>Interface address add   : (with address 10.10.10.50)
>
>Interface address delete: (with address 10.10.10.50)
>Interface address add   : (with address 10.10.10.50)
>
>Interface address delete: (with address 10.10.10.50)
>Interface address add   : (with address 10.10.10.50)
>
>Ideally as only the interface address is changed only one address
>delete/add should be sent.

State is not maintained in user space. You change that IP address,
it actually gets deleted then a new one added. The bcast and netmask
changeto defaults  as a result; you then change the netmask and
broadcast with each requiring a call from user space. If you modify your
netlink program to print both net and broadcast address you should see
this. BTW, you MUST check for these.

Example try just:
ifconfig eth0 10.10.10.50

and after you change it try:
ifconfig eth0 10.10.10.50 netmask 0xffffff00

and then
ifconfig eth0 10.10.10.50 netmask 0xffffff00 broadcast 10.10.10.255

cheers,
jamal
