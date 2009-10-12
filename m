From: Rob Townley <rob.townley@gmail.com>
Subject: Re: Ping Is Broken
Date: Mon, 12 Oct 2009 14:14:13 -0500
Message-ID: <7e84ed60910121214n71413383v3ee703ea6042f355@mail.gmail.com>
References: <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com>
	 <20091012094752.GA8114@ff.dom.local>
Reply-To: Rob.Townley@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: CentOS mailing list
	<public-centos-IFYaIzF+flcdnm+yROfE0A@plane.gmane.org>,
	public-netdev-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org,
	Omaha Linux User Group
	<public-olug-u8lKhlSLHjY@plane.gmane.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:39891 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933079AbZJLTQu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 15:16:50 -0400
Received: from public by plane.gmane.org with local (Exim 4.63)
	(envelope-from <public@plane.gmane.org>)
	id 1MxQNQ-0004U1-OS
	for netdev@vger.kernel.org; Mon, 12 Oct 2009 21:16:12 +0200
In-Reply-To: <20091012094752.GA8114@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On Mon, Oct 12, 2009 at 4:47 AM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
>
>
> On 09-10-2009 18:44, Rob Townley wrote:
>> ping -I is broken
>>
>> The following deals with bug in ping that made it very difficult to =
set up a
>> system with two gateways.
>>
>> Demonstration that *ping -I is broken*. When specifying the source
>> interface using -I with an *ethX* alias and that interface is not th=
e
>> default gateway
>> interface, then ping fails. When specifying the interface as an ip a=
ddress,
>> ping works. Search for "Destination Host Unreachable" to find the bu=
g.
>>
>>
>> eth*0* =3D 4.3.2.8 and the default gateway is accessed through a dif=
ferent
>> interface eth*1*.
>> eth*1* =3D 192.168.168.155 is used as the device to get to the defau=
lt
>> gateway.
>> *FAILS *: ping *-I eth0* 208.67.222.222
>> *WORKS*: ping *-I 4.3.2.8* 208.67.222.222
>> *WORKS*: ping *-I eth1* 208.67.222.222
>> *WORKS*: ping *-I 192.168.168.155* 208.67.222.222
> ...
>> man ping:
>> =A0 =A0-I interface address
>> =A0 =A0 =A0 =A0 Set source address to specified interface address.
>> =A0 =A0 =A0 =A0 Argument may be *numeric IP address or name of devic=
e*.
>> =A0 =A0 =A0 =A0 When =A0pinging =A0IPv6 =A0link-local =A0address =A0=
this option is required.
>
> It seems this description might be misleading that IP address and nam=
e
> of device are equivalent here, while they are treated a bit different=
=2E
> The device name is additionally used in a sendmsg message, probably t=
o
> guarantee the device is really used (not its address only), so it
> looks like intended.
>
>> ping -V returns the latest available on CentOS and Fedora and the
>> maintainers website:
>> ping utility, iputils-ss020927
>
> I guess the patch below could do what you expect in this case, but
> rather "man" should be fixed...

Thank you for the patch.  i will test it. i was trying to find the
problem using gdb and figure out a patch myself.

ping used to work the way i expected many many years ago on various
*nix systems.
Besides, traceroute is broken by the same problem except that
traceroute is much more explicit with a -i and -s parameters.  Who
knows what else is broken by all the meddling in interface name
aliases without testing.

MultiNic / MultiGatewayed machines are hard enough in Linux, lets not
give users a reason to use BSD or Windows.

>
> Jarek P.
> ---
>
> --- ping.c.orig 2002-09-20 15:08:11.000000000 +0000
> +++ ping.c =A0 =A0 =A02009-10-12 08:51:25.000000000 +0000
> @@ -323,7 +323,7 @@ main(int argc, char **argv)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0perror("ping: icmp open socket");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0exit(2);
> =A0 =A0 =A0 =A0}
> -
> +#if 0
> =A0 =A0 =A0 =A0if (device) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct ifreq ifr;
>
> @@ -336,7 +336,7 @@ main(int argc, char **argv)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cmsg.ipi.ipi_ifindex =3D ifr.ifr_ifind=
ex;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cmsg_len =3D sizeof(cmsg);
> =A0 =A0 =A0 =A0}
> -
> +#endif
> =A0 =A0 =A0 =A0if (broadcast_pings || IN_MULTICAST(ntohl(whereto.sin_=
addr.s_addr))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (uid) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (interval < 1000) {
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>


