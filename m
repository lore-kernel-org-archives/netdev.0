From: zhuyj <zyjzyj2000@gmail.com>
Subject: How to identify different ip tunnels
Date: Thu, 23 Jan 2014 15:33:11 +0800
Message-ID: <52E0C5B7.7040908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, linux-kernel@vger.kernel.org,
	zhuyj <zyjzyj2000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Maintainers

We want to identify different ip tunnels.

=46or example, we use =93ip tunnel add xxx=94 command in linux to creat=
e an=20
ipv4/6 tunnel interface,then,we can receive a RTM_NEWLINK message from=20
linux for the new tunnel interface.
We will parse the struct ifinfomsg message and get the ifi->ifi_type=20
attribute. We need to do somethings depend on the tunnel type here.
I checked the linux source code and list all the tunnel types here:

#define ARPHRD_TUNNEL 768 /* IPIP tunnel */
#define ARPHRD_TUNNEL6 769 /* IP6IP6 tunnel */
#define ARPHRD_SIT 776 /* sit0 device - IPv6-in-IPv4 */
#define ARPHRD_IPGRE 778 /* GRE over IP */

It means that the linux will report the new link for any ipv4/6 tunnel=20
interface with type only within these four types. However, We need more=
=20
tunnel types for ipv4/6 tunnel.
=46or example, 4IN4/6IN4/6TO4/GRE/ISATAP for ipv4 tunnel and=20
4IN6/6IN6/IPIN6 for ipv6 tunnel.

Here are the result that we have got:

Actual Tunnel type ifi->ifi_type
4IN4 768
GRE4 778
6IN4/6TO4/ISATAP 776
4IN6/6IN6/IPIN6 769

So, we can NOT distinguish the actual tunnel type via ifi_type attribut=
e=20
except the GRE4 and 4IN4 tunnel. However we need the actual type. That=20
is our question.

BTW, for the 6IN4 and 6TO4 tunnel, Can we distinguish them before the=20
interface ip address configured? Because we need to do different things=
=20
for them when we received the new link message and the tunnel has NOT=20
any ip address in this time.

Best Regards!
Zhu Yanjun
