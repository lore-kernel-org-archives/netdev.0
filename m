From: =?UTF-8?B?QW7DrWJhbCBBbG1laWRhIFBpbnRv?= <anibal.pinto@efacec.com>
Subject: Re: Gianfar ethernet drop package
Date: Mon, 27 Aug 2012 14:01:27 +0100
Message-ID: <503B6FA7.8070807@efacec.com>
References: <5037A86E.2000004@efacec.com>  <1345832223.19483.75.camel@edumazet-glaptop>  <503B4CBB.1020405@efacec.com> <1346065738.2420.135.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.efacec.com ([62.28.144.243]:13549 "HELO mail2.efacec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750839Ab2H0NBc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 09:01:32 -0400
In-Reply-To: <1346065738.2420.135.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 27-08-2012 12:08, Eric Dumazet escreveu:
> On Mon, 2012-08-27 at 11:32 +0100, An=C3=ADbal Almeida Pinto wrote:
>
>> I generate the log on the board with tcpdump -i eth0 -w log_eth0.txt=
 and
>> loaded the result on wireshark (on other pc).
>>
>> On the wireshark everything appears to be fine don't have nothing th=
at
>> indicate the protocol isn't supported.
>>
>> On /etc/protocols is a list with protocols, it there is a place wher=
e
>> exist a place with protocols supported by kernel ?
>
> So all frames understood by wireshark are also automatically handled =
by
> your linux machine ? That sounds cool, so we no longer have to add st=
uff
> in the kernel ?
>
> Let me explain again :
>
> For example, if you dont have IPv6 loaded, IPv6 frames wont be handle=
d,
> and they appear to be dropped. They really are.
>
> If you run tcpdump/wireshark, these frames are at least delivered onc=
e
> to a sniffer, so they are not "dropped", even if no protocol handler
> actually reacts to them.

I understand your explanation.

My problem now is to identify why the packages were dropped.

Wireshark report what listen and with ifconfig I only know how many hav=
e=20
been dropped.

I made a program, inline at the end, that tries to see the sockets that=
=20
I can create on a system, that will give me a idea of what protocol=20
handler that I have.

The program isn't complete and the options are a lot ...

Even with this I only can see the log of tcpdump and try to find frames=
=20
that belong to protocols not supported, don't know if there isn't=20
another reason, like Softnet backlog full or Bad / Unintended VLAN tags

Is there any way of put tcpdump or other tool to only log the packages=20
dropped ?

Thanks

#include <stdio.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>

#include <netdb.h>

#include <errno.h>

struct socket_conf {
	int socket_family; // domain
	int socket_type;
	int protocol;
};


struct socket_conf conf_list[] =3D {
	{ PF_LOCAL, SOCK_STREAM, 0 },	// Local stream socket
	{ PF_LOCAL, SOCK_DGRAM, 0 },	// Local datagram socket
	{ PF_INET, SOCK_STREAM, IPPROTO_TCP }, // TCP/IP stream socket
	{ PF_INET, SOCK_DGRAM, IPPROTO_UDP}, // UDP datagram socket
	{ PF_UNSPEC, SOCK_DGRAM , 0 },
	{ PF_LOCAL, SOCK_DGRAM , 0 },
	{ PF_UNIX, SOCK_DGRAM , 0 },
	{ PF_FILE, SOCK_DGRAM , 0 },
	{ PF_INET, SOCK_DGRAM , 0 },
//	{ PF_AX, SOCK_DGRAM , 0 },
	{ PF_IPX, SOCK_DGRAM , 0 },
	{ PF_APPLETALK, SOCK_DGRAM , 0 },
	{ PF_NETROM, SOCK_DGRAM , 0 },
	{ PF_BRIDGE, SOCK_DGRAM , 0 },
	{ PF_ATMPVC, SOCK_DGRAM , 0 },
//	{ PF_X, SOCK_DGRAM , 0 },
	{ PF_INET, SOCK_DGRAM , 0 },
	{ PF_ROSE, SOCK_DGRAM , 0 },
	{ PF_DECnet, SOCK_DGRAM , 0 },
	{ PF_NETBEUI, SOCK_DGRAM , 0 },
	{ PF_SECURITY, SOCK_DGRAM , 0 },
	{ PF_KEY, SOCK_DGRAM , 0 },
	{ PF_NETLINK , SOCK_DGRAM , 0 },
	{ PF_ROUTE , SOCK_DGRAM , 0 },
	{ PF_PACKET, SOCK_DGRAM , 0 },
	{ PF_ASH, SOCK_DGRAM , 0 },
	{ PF_ECONET, SOCK_DGRAM , 0 },
	{ PF_ATMSVC, SOCK_DGRAM , 0 },
	{ PF_SNA, SOCK_DGRAM , 0 },
	{ PF_IRDA, SOCK_DGRAM , 0 },
	{ PF_MAX, SOCK_DGRAM , 0 },
	{ AF_UNSPEC  , SOCK_DGRAM , 0 },
	{ AF_LOCAL  , SOCK_DGRAM , 0 },
	{ AF_UNIX  , SOCK_DGRAM , 0 },
	{ AF_FILE , SOCK_DGRAM , 0 },
	{ AF_INET, SOCK_DGRAM , 0 },
	{ AF_AX25, SOCK_DGRAM , 0 },
	{ AF_IPX , SOCK_DGRAM , 0 },
	{ AF_APPLETALK  , SOCK_DGRAM , 0 },
	{ AF_NETROM    , SOCK_DGRAM , 0 },
	{ AF_BRIDGE   , SOCK_DGRAM , 0 },
	{ AF_ATMPVC  , SOCK_DGRAM , 0 },
	{ AF_X25    , SOCK_DGRAM , 0 },
	{ AF_INET6 , SOCK_DGRAM , 0 },
	{ AF_ROSE   , SOCK_DGRAM , 0 },
	{ AF_DECnet  , SOCK_DGRAM , 0 },
	{ AF_NETBEUI  , SOCK_DGRAM , 0 },
	{ AF_SECURITY , SOCK_DGRAM , 0 },
//	{ pseudo_AF_KEY , SOCK_DGRAM , 0 },
	{ AF_NETLINK   , SOCK_DGRAM , 0 },
	{ AF_ROUTE    , SOCK_DGRAM , 0 },
	{ AF_PACKET  , SOCK_DGRAM , 0 },
	{ AF_ASH    , SOCK_DGRAM , 0 },
	{ AF_ECONET , SOCK_DGRAM , 0 },
	{ AF_ATMSVC , SOCK_DGRAM , 0 },
	{ AF_SNA   , SOCK_DGRAM , 0 },
	{ AF_IRDA , SOCK_DGRAM , 0 },
	{ AF_MAX  , SOCK_DGRAM , 0 },
};


int main(int argc, char * argv[]){

	int s, i;
	struct protoent * p;

	setprotoent(0);

	for(i =3D 0 ; i < sizeof(conf_list) / sizeof(struct socket_conf) ; i++=
) {

		p =3D getprotobynumber(conf_list[i].socket_family);

		printf("Index %d", i);

		if(p !=3D NULL)
			printf(" prot %s", p->p_name);

		printf(" : ");=09
				fflush(stdout);

		s =3D socket(conf_list[i].socket_family,
				conf_list[i].socket_type,
				conf_list[i].protocol
				);

		if( s =3D=3D -1)
			perror("socket()");
		else
			printf("ok\n");

		fflush(stdout);
	}

	endprotoent();

	return 1;
}
