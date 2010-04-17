From: unni krishnan <unnikrishnan.a@gmail.com>
Subject: Re: Duplicate IP false alerts from arping
Date: Sun, 18 Apr 2010 01:09:13 +0530
Message-ID: <u2o1f8bbe3c1004171239wbab76e2l7c41b8e608450bc6@mail.gmail.com>
References: <m2v1f8bbe3c1004152351o580b37ebx55e428fb106b09bd@mail.gmail.com>
	 <j2m1f8bbe3c1004162111mf87a7fbck9e8eafb36be48687@mail.gmail.com>
	 <4BC9784B.3020103@plouf.fr.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Pascal Hambourg <pascal.mail@plouf.fr.eu.org>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <4BC9784B.3020103@plouf.fr.eu.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, then what is the best method to find the duplicate IP ( same IP
address assigned to different machines ) ?

On Sat, Apr 17, 2010 at 2:28 PM, Pascal Hambourg
<pascal.mail@plouf.fr.eu.org> wrote:
> Hello,
>
> unni krishnan a =E9crit :
>>
>> I am trying to find a duplicate IP in the network using arping.
>>
>> =A0-------------------------
>> =A0[root@vps1 ~]# ping -c 3 192.168.1.212
>> =A0PING 192.168.1.212 (192.168.1.212) 56(84) bytes of data.
>> =A064 bytes from 192.168.1.212: icmp_seq=3D1 ttl=3D64 time=3D1.33 ms
>> =A064 bytes from 192.168.1.212: icmp_seq=3D2 ttl=3D64 time=3D0.280 m=
s
>> =A064 bytes from 192.168.1.212: icmp_seq=3D3 ttl=3D64 time=3D0.306 m=
s
>>
>> =A0--- 192.168.1.212 ping statistics ---
>> =A03 packets transmitted, 3 received, 0% packet loss, time 1999ms
>> =A0rtt min/avg/max/mdev =3D 0.280/0.641/1.339/0.494 ms
>> =A0[root@vps1 ~]# arping -D -I eth0 -c 5 192.168.1.212 ; echo $?
>> =A0ARPING 192.168.1.212 from 0.0.0.0 eth0
>> =A00
>> =A0-------------------------
>>
>> =A0As per arping that IP is duplicate.
>
> I disagree. According to man arping :
>
> =A0 =A0-D =A0Duplicate =A0address =A0detection =A0mode =A0(DAD). =A0S=
ee RFC2131, 4.4.1.
> =A0 =A0 =A0 =A0Returns 0, if DAD succeeded i.e. no replies are receiv=
ed
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 ^^^^^^^^^^^^^^^^^^^^^^^
> -D (DAD) is meant for DHCP to find out if the proposed IP address is =
not
> already assigned to another host. Its purpose is not to find out if
> multiple hosts have the same IP address. Besides, a return value of 0
> means that no ARP replies were received (IOW -D inverts the return va=
lue
> logic), which is weird since the target IP address replies to ICMP pi=
ng
> unless that address is assigned to the local host.
>
> Here :
>
> # arping -DI eth0 -c 1 192.168.0.246 ; echo result=3D$?
> ARPING 192.168.0.246 from 0.0.0.0 eth0
> Unicast reply from 192.168.0.246 [xx:xx:xx:xx:xx:xx] =A00.964ms
> Sent 1 probes (1 broadcast(s))
> Received 1 response(s)
> result=3D1
>
> # arping -DI eth0 -c 1 192.168.0.24 ; echo result=3D$?
> ARPING 192.168.0.24 from 0.0.0.0 eth0
> Sent 1 probes (1 broadcast(s))
> Received 0 response(s)
> result=3D0
>
>> But if I go ahead and ifdown the
>> =A0IP in the known location I cant ping that IP ( That means that IP=
 is
>> =A0not duplicated ? ). This is the result after shutting down the IP=
=2E
>>
>> =A0--------------------------
>> =A0[root@vps1 ~]# ping -c 3 192.168.1.212
>> =A0PING 192.168.1.212 (192.168.1.212) 56(84) bytes of data.
>> =A0From 192.168.1.63 icmp_seq=3D1 Destination Host Unreachable
>> =A0From 192.168.1.63 icmp_seq=3D2 Destination Host Unreachable
>> =A0From 192.168.1.63 icmp_seq=3D3 Destination Host Unreachable
>
> Ok, that means no ARP reply.
>
>> =A0[root@vps1 ~]# arping -D -I eth0 -c 5 192.168.1.212 ; echo $?
>> =A0ARPING 192.168.1.212 from 0.0.0.0 eth0
>> =A0Sent 5 probes (5 broadcast(s))
>> =A0Received 0 response(s)
>> =A00
>
> Same as above.
>
>> =A0My question is, in this case IP 192.168.1.212 is not duplicated. =
But
>> =A0still arping gives duplicate status. Why it is like that ?
>
> A situation of real duplicate ARP replies may occur when the address =
is
> assigned to a host which has multiple interfaces connected to the sam=
e
> network, so it receives and replies to ARP queries on each interface.
>



--=20
Regards,
Unni
http://mutexes.org/
http://twitter.com/webofunni
