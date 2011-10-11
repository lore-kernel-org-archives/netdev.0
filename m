From: Francis SOUYRI <francis.souyri@apec.fr>
Subject: Re: loopback IP alias breaks tftp?
Date: Tue, 11 Oct 2011 09:28:05 +0200
Message-ID: <4E93F005.8050002@apec.fr>
References: <20111005202723.GE2479@zod.bos.redhat.com> <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg> <20111006132353.GF2479@zod.bos.redhat.com> <CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com> <1317972573.3457.55.camel@edumazet-laptop> <20111007114017.GA1165@zod.bos.redhat.com> <1317989073.3207.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1317990201.3207.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111010151058.GD1165@zod.bos.redhat.com> <CAGVGHmsF3JBqpqzKa_Fp6oOcVKX5BKgJUG=UJvPZcNgKiSsrRA@mail.gmail.com> <1318260126.3227.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAGVGHmt4_kf5XTS745aMa9kuxb1Fu9v8f6boG-vewVeto5jJ=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Josh Boyer <jwboyer@redhat.com>, Joel Sing <jsing@google.com>,
	Julian Anastasov <ja@ssi.bg>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Olaf van der Spek <ml@vdspek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vador.apec.fr ([195.167.194.26]:38481 "EHLO vador.apec.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750872Ab1JKHhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 03:37:07 -0400
In-Reply-To: <CAGVGHmt4_kf5XTS745aMa9kuxb1Fu9v8f6boG-vewVeto5jJ=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I put this in the Red Hat Bugzilla =96 Bug 739534:

#####=09

I do the test with the bind of the IP alias (for test purpose=20
127.0.0.2), but I have the same problem.

# ifconfig lo; ifconfig lo:0
lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:24418 errors:0 dropped:0 overruns:0 frame:0
           TX packets:24418 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:3798250 (3.6 MiB)  TX bytes:3798250 (3.6 MiB)

lo:0      Link encap:Local Loopback
           inet addr:127.0.0.2  Mask:255.0.0.0
           UP LOOPBACK RUNNING  MTU:16436  Metric:1

# netstat -an | grep 69 | grep udp
udp        0      0 127.0.0.2:69                0.0.0.0:*=20

udp        0      0 :::52697                    :::*=20

# tftp 127.0.0.2
tftp> trace
Packet tracing on.
tftp> get /thinstation/dell/vmlinuz
sent RRQ <file=3D/thinstation/dell/vmlinuz, mode=3Dnetascii>
received DATA <block=3D1, 512 bytes>
sent ACK <block=3D1>
received DATA <block=3D1, 512 bytes>
sent ACK <block=3D1>
received DATA <block=3D1, 512 bytes>
sent ACK <block=3D1>
received DATA <block=3D1, 512 bytes>
sent ACK <block=3D1>
sent ACK <block=3D1>
received DATA <block=3D1, 512 bytes>
sent ACK <block=3D1>
sent ACK <block=3D1>
sent ACK <block=3D1>
sent ACK <block=3D1>
received DATA <block=3D1, 512 bytes>
sent ACK <block=3D1>
Transfer timed out.

tftp>

I do also this test, I changed the local route (the loopback used is=20
only for test purpose, in production I used 192.168.100.0/24 network).

# ip route show table local | grep 127.0.0.
broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1
local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1
local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1
local 127.0.0.2 dev lo  proto kernel  scope host  src 127.0.0.1
broadcast 127.255.255.255 dev lo  proto kernel  scope link  src 127.0.0=
=2E1
#
# ip route change local 127.0.0.2 dev lo  proto kernel  scope host  src
127.0.0.2
#
# ip route show table local | grep 127.0.0.
broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1
local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1
local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1
local 127.0.0.2 dev lo  proto kernel  scope host  src 127.0.0.2
broadcast 127.255.255.255 dev lo  proto kernel  scope link  src 127.0.0=
=2E1
#
# tftp 127.0.0.2
tftp> get /thinstation/dell/vmlinuz
tftp> quit
#
# ip route change local 127.0.0.2 dev lo  proto kernel  scope host  src
127.0.0.1
# tftp 127.0.0.2
tftp> get /thinstation/dell/vmlinuz
Transfer timed out.

tftp> quit
#

#####

Best regards.

=46rancis


On 10/10/2011 05:25 PM, Olaf van der Spek wrote:
> On Mon, Oct 10, 2011 at 5:22 PM, Eric Dumazet<eric.dumazet@gmail.com>=
  wrote:
>>> Isn't that a bad way to work around this issue?
>>> It'd require you to duplicate your IP config for every daemon that
>>> listens on UDP interfaces.
>>> What about IP addresses that are added/deleted after the daemon is =
launchad?
>>>
>>> Olaf
>>
>> Thats a pretty common problem, even prior to discussed commit.
>>
>> If you take a look at common UDP daemons, they have to setup a liste=
ner
>> for each IP address, OR use the correct API ( setsockopt(fd, IPPROTO=
_IP,
>> &on, sizeof(on)) and handle IP_PKTINFO ancillary message)
>
> Only the latter solution seems right.
>
> Olaf
>
