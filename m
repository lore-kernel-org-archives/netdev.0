From: "Md Arif" <arif7290@hotmail.com>
Subject: Linux IPv6 Bind failure with Invalid Argument
Date: Fri, 19 Apr 2002 18:29:53 +0000
Sender: owner-netdev@oss.sgi.com
Message-ID: <F241xbWbsAyTabSMvfR0001924a@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
   Would you pls help me out in this regard. I am getting Bind failure wi=
th=20
error inValid argument Linux IPv6 machine(Kernel 2.4.7)
   Same code works in Solaris IPv6.
   Where is is bug?????
   Pls let me know if you need more info on this.

   Thanks in advance for your support.
   Arif

   /*-------------- code segment ------------------*/

   struct sockaddr_in6 addr6;
   int size, sd;

   sd =3D socket(AF_INET6, SOCK_DGRAM, 0);

   if(sd =3D=3D -1)
   {
      perror("socket()"); exit(1);
   }

   if(setsockopt(sd, SOL_SOCKET, SO_BSDCOMPAT, &enable, sizeof(enable)) =3D=
=3D=20
-1)
   {
      perror("setsockopt()");
      exit(1);
   }

   if(setsockopt(sd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(enable)) =3D=
=3D=20
-1)
   {
      perror("setsockopt()");
      exit(1);
   }

   memset(&addr6, 0, sizeof(addr6));
   size =3D sizeof(struct sockaddr_in6);
   addr6.sin6_family =3D AF_INET6;
   addr6.sin6_port =3D htons(0);

   /* use this to bind to real address */
   if(inet_pton(AF_INET6, "FE80::250:DAFF:FECD:2DE2", &addr6.sin6_addr)=3D=
=3D0)
      perror("inet_pton call failed inside cmInetBind");

   /* when binding to loopback interface. THIS PORTION WORKS!!!! */
   /* memcpy(&addr6.sin6_addr, &in6addr_loopback, sizeof(in6addr_loopback=
));=20
*/=A0

   if(bind(sd, (struct sockaddr *)&addr6, size) =3D=3D -1)
   {
      perror("bind()"); exit(1);
   }

   ------------log of the Interface on linux IPv6 machine------------

eth0      Link encap:Ethernet  HWaddr 00:50:DA:CD:2D:E2
          inet addr:10.242.101.18  Bcast:10.242.101.255 Mask:255.255.255.=
0
          inet6 addr: fe80::250:daff:fecd:2de2/10 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:3109744 errors:0 dropped:0 overruns:136 frame:0
          TX packets:2470093 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0
          RX bytes:650222683 (620.1 Mb)  TX bytes:541913530 (516.8 Mb)


_________________________________________________________________
Send and receive Hotmail on your mobile device: http://mobile.msn.com
