From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: am335x: no multicast reception over VLAN
Date: Thu, 31 Mar 2016 09:52:53 +0200
Message-ID: <CAGm1_kutVn+jNf58QwKyO8j5NmRhaOCUsXmpTiLbX75AczCm6w@mail.gmail.com>
References: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
 <56F9FDD0.8030504@ti.com> <CAGm1_ksxRPCAqx4n5gbsARSYeF116BT7r8cC6=1QYnEsYRxpVw@mail.gmail.com>
 <56FA616C.9080502@ti.com> <CAGm1_ksvEdk-mF-hW4o5+bri6J6sMgnQQVD3j-e7xm6PsP8k0A@mail.gmail.com>
 <56FA78AA.4030402@ti.com> <56FB6543.9060904@ti.com> <CAGm1_kvXA4egrK8-oCedYjvPm7BhJdy_w-5ON24snYdKiN3K7g@mail.gmail.com>
 <56FC0431.5000106@ti.com> <878u0z9297.fsf@dell.be.48ers.dk> <56FCC59B.70209@ti.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1144a0e4e6d4c4052f538da9
Cc: Peter Korsgaard <peter@korsgaard.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	drivshin@allworx.com, ml@markusgrimm.de
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:36400 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754429AbcCaHxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 03:53:14 -0400
In-Reply-To: <56FCC59B.70209@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1144a0e4e6d4c4052f538da9
Content-Type: text/plain; charset=UTF-8

On Thu, Mar 31, 2016 at 8:37 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> On Thursday 31 March 2016 01:17 AM, Peter Korsgaard wrote:
>>>>>>> "Mugunthan" == Mugunthan V N <mugunthanvnm@ti.com> writes:
>>
>> Hi,
>>
>>  > You had received these packets as tcpdump will enable promiscuous mode
>>  > so that you receive all the packets from the wire.
>>
>> FYI, you can use the -p option to tcpdump to not put the interface into
>> promiscuous mode.
>>
>
> Thanks for the information Peter Korsgaard.
>
> Yegor, can you provide tcpdump using -p as well in Grygorii commands.

Before VLAN configuration:

# switch-config -d
cpsw hw version 1.12 (0)
0   : type: vlan , vid = 1, untag_force = 0x3, reg_mcast = 0x3,
unreg_mcast = 0x0, member_list = 0x3
1   : type: mcast, vid = 1, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
no super, port_mask = 0x3
2   : type: ucast, vid = 1, addr = 74:6a:8f:00:16:12, ucast_type =
persistant, port_num = 0x0, Secure
3   : type: vlan , vid = 0, untag_force = 0x7, reg_mcast = 0x0,
unreg_mcast = 0x0, member_list = 0x7
4   : type: mcast, vid = 1, addr = 01:00:5e:00:00:01, mcast_state = f,
no super, port_mask = 0x3
5   : type: vlan , vid = 2, untag_force = 0x5, reg_mcast = 0x5,
unreg_mcast = 0x0, member_list = 0x5
6   : type: mcast, vid = 2, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
no super, port_mask = 0x5
7   : type: ucast, vid = 2, addr = 74:6a:8f:00:16:13, ucast_type =
persistant, port_num = 0x0, Secure
8   : type: mcast, vid = 2, addr = 01:00:5e:00:00:01, mcast_state = f,
no super, port_mask = 0x5

After VLAN configuration:

# switch-config -d
cpsw hw version 1.12 (0)
0   : type: vlan , vid = 1, untag_force = 0x3, reg_mcast = 0x3,
unreg_mcast = 0x0, member_list = 0x3
1   : type: mcast, vid = 1, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
no super, port_mask = 0x3
2   : type: ucast, vid = 1, addr = 74:6a:8f:00:16:12, ucast_type =
persistant, port_num = 0x0, Secure
3   : type: vlan , vid = 0, untag_force = 0x7, reg_mcast = 0x0,
unreg_mcast = 0x0, member_list = 0x7
4   : type: mcast, vid = 1, addr = 01:00:5e:00:00:01, mcast_state = f,
no super, port_mask = 0x3
5   : type: vlan , vid = 2, untag_force = 0x5, reg_mcast = 0x5,
unreg_mcast = 0x0, member_list = 0x5
6   : type: mcast, vid = 2, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
no super, port_mask = 0x5
7   : type: ucast, vid = 2, addr = 74:6a:8f:00:16:13, ucast_type =
persistant, port_num = 0x0, Secure
8   : type: mcast, vid = 2, addr = 01:00:5e:00:00:01, mcast_state = f,
no super, port_mask = 0x5
9   : type: vlan , vid = 100, untag_force = 0x0, reg_mcast = 0x5,
unreg_mcast = 0x0, member_list = 0x5
10  : type: ucast, vid = 100, addr = 74:6a:8f:00:16:13, ucast_type =
persistant, port_num = 0x0
11  : type: mcast, vid = 100, addr = ff:ff:ff:ff:ff:ff, mcast_state =
f, no super, port_mask = 0x5
12  : type: mcast, vid = 2, addr = 01:80:c2:00:00:21, mcast_state = f,
no super, port_mask = 0x5

During mulitcast receive:

# switch-config -d
cpsw hw version 1.12 (0)
0   : type: vlan , vid = 1, untag_force = 0x3, reg_mcast = 0x3,
unreg_mcast = 0x0, member_list = 0x3
1   : type: mcast, vid = 1, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
no super, port_mask = 0x3
2   : type: ucast, vid = 1, addr = 74:6a:8f:00:16:12, ucast_type =
persistant, port_num = 0x0, Secure
3   : type: vlan , vid = 0, untag_force = 0x7, reg_mcast = 0x0,
unreg_mcast = 0x0, member_list = 0x7
4   : type: mcast, vid = 1, addr = 01:00:5e:00:00:01, mcast_state = f,
no super, port_mask = 0x3
5   : type: vlan , vid = 2, untag_force = 0x5, reg_mcast = 0x5,
unreg_mcast = 0x0, member_list = 0x5
6   : type: mcast, vid = 2, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
no super, port_mask = 0x5
7   : type: ucast, vid = 2, addr = 74:6a:8f:00:16:13, ucast_type =
persistant, port_num = 0x0, Secure
8   : type: mcast, vid = 2, addr = 01:00:5e:00:00:01, mcast_state = f,
no super, port_mask = 0x5
9   : type: vlan , vid = 100, untag_force = 0x0, reg_mcast = 0x5,
unreg_mcast = 0x0, member_list = 0x5
10  : type: ucast, vid = 100, addr = 74:6a:8f:00:16:13, ucast_type =
persistant, port_num = 0x0
11  : type: mcast, vid = 100, addr = ff:ff:ff:ff:ff:ff, mcast_state =
f, no super, port_mask = 0x5
12  : type: mcast, vid = 2, addr = 01:80:c2:00:00:21, mcast_state = f,
no super, port_mask = 0x5
13  : type: mcast, vid = 2, addr = 01:00:5e:03:1d:47, mcast_state = f,
no super, port_mask = 0x5
14  : type: ucast, vid = 100, addr = 66:22:04:bc:90:26, ucast_type =
untouched , port_num = 0x2


After multicast receive use case:

# switch-config -d
cpsw hw version 1.12 (0)
0   : type: vlan , vid = 1, untag_force = 0x3, reg_mcast = 0x3,
unreg_mcast = 0x0, member_list = 0x3
1   : type: mcast, vid = 1, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
no super, port_mask = 0x3
2   : type: ucast, vid = 1, addr = 74:6a:8f:00:16:12, ucast_type =
persistant, port_num = 0x0, Secure
3   : type: vlan , vid = 0, untag_force = 0x7, reg_mcast = 0x0,
unreg_mcast = 0x0, member_list = 0x7
4   : type: mcast, vid = 1, addr = 01:00:5e:00:00:01, mcast_state = f,
no super, port_mask = 0x3
5   : type: vlan , vid = 2, untag_force = 0x5, reg_mcast = 0x5,
unreg_mcast = 0x0, member_list = 0x5
6   : type: mcast, vid = 2, addr = ff:ff:ff:ff:ff:ff, mcast_state = f,
no super, port_mask = 0x5
7   : type: ucast, vid = 2, addr = 74:6a:8f:00:16:13, ucast_type =
persistant, port_num = 0x0, Secure
8   : type: mcast, vid = 2, addr = 01:00:5e:00:00:01, mcast_state = f,
no super, port_mask = 0x5
9   : type: vlan , vid = 100, untag_force = 0x0, reg_mcast = 0x5,
unreg_mcast = 0x0, member_list = 0x5
10  : type: ucast, vid = 100, addr = 74:6a:8f:00:16:13, ucast_type =
persistant, port_num = 0x0
11  : type: mcast, vid = 100, addr = ff:ff:ff:ff:ff:ff, mcast_state =
f, no super, port_mask = 0x5
12  : type: mcast, vid = 2, addr = 01:80:c2:00:00:21, mcast_state = f,
no super, port_mask = 0x5
15  : type: ucast, vid = 100, addr = 66:22:04:bc:90:26, ucast_type =
untouched , port_num = 0x2

Both tcpdumps with -p option showed no packets. If I execute ping, I
can see related ICMP packets. addr = 66:22:04:bc:90:26 is PandaBoards
MAC.

Btw I've attached my test scripts (mcastr.py - multicast receiver and
mcastt.py - multicast transmitter). Could you reproduce my setup?

Thanks.

Yegor

--001a1144a0e4e6d4c4052f538da9
Content-Type: text/plain; charset=US-ASCII; name="mcastr.py"
Content-Disposition: attachment; filename="mcastr.py"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_imfzeo620

aW1wb3J0IHNvY2tldAppbXBvcnQgc3RydWN0CmltcG9ydCBzeXMKCm11bHRpY2FzdF9ncm91cCA9
ICcyMjQuMy4yOS43MScKc2VydmVyX2FkZHJlc3MgPSAoJycsIDEwMDAwKQoKIyBDcmVhdGUgdGhl
IHNvY2tldApzb2NrID0gc29ja2V0LnNvY2tldChzb2NrZXQuQUZfSU5FVCwgc29ja2V0LlNPQ0tf
REdSQU0pCgojIEJpbmQgdG8gdGhlIHNlcnZlciBhZGRyZXNzCnNvY2suYmluZChzZXJ2ZXJfYWRk
cmVzcykKCiMgVGVsbCB0aGUgb3BlcmF0aW5nIHN5c3RlbSB0byBhZGQgdGhlIHNvY2tldCB0byB0
aGUgbXVsdGljYXN0IGdyb3VwCiMgb24gYWxsIGludGVyZmFjZXMuCmdyb3VwID0gc29ja2V0Lmlu
ZXRfYXRvbihtdWx0aWNhc3RfZ3JvdXApCm1yZXEgPSBzdHJ1Y3QucGFjaygnNHNMJywgZ3JvdXAs
IHNvY2tldC5JTkFERFJfQU5ZKQpzb2NrLnNldHNvY2tvcHQoc29ja2V0LklQUFJPVE9fSVAsIHNv
Y2tldC5JUF9BRERfTUVNQkVSU0hJUCwgbXJlcSkKCiMgUmVjZWl2ZS9yZXNwb25kIGxvb3AKd2hp
bGUgVHJ1ZToKICAgIHByaW50ID4+c3lzLnN0ZGVyciwgJ1xud2FpdGluZyB0byByZWNlaXZlIG1l
c3NhZ2UnCiAgICBkYXRhLCBhZGRyZXNzID0gc29jay5yZWN2ZnJvbSgxMDI0KQogICAgCiAgICBw
cmludCA+PnN5cy5zdGRlcnIsICdyZWNlaXZlZCAlcyBieXRlcyBmcm9tICVzJyAlIChsZW4oZGF0
YSksIGFkZHJlc3MpCiAgICBwcmludCA+PnN5cy5zdGRlcnIsIGRhdGEKCiAgICBwcmludCA+PnN5
cy5zdGRlcnIsICdzZW5kaW5nIGFja25vd2xlZGdlbWVudCB0bycsIGFkZHJlc3MKICAgIHNvY2su
c2VuZHRvKCdhY2snLCBhZGRyZXNzKQo=
--001a1144a0e4e6d4c4052f538da9
Content-Type: text/plain; charset=US-ASCII; name="mcastt.py"
Content-Disposition: attachment; filename="mcastt.py"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_imfzevjt1

aW1wb3J0IHNvY2tldAppbXBvcnQgc3RydWN0CmltcG9ydCBzeXMKCm1lc3NhZ2UgPSAndmVyeSBp
bXBvcnRhbnQgZGF0YScKbXVsdGljYXN0X2dyb3VwID0gKCcyMjQuMy4yOS43MScsIDEwMDAwKQoK
IyBDcmVhdGUgdGhlIGRhdGFncmFtIHNvY2tldApzb2NrID0gc29ja2V0LnNvY2tldChzb2NrZXQu
QUZfSU5FVCwgc29ja2V0LlNPQ0tfREdSQU0pCgojIFNldCBhIHRpbWVvdXQgc28gdGhlIHNvY2tl
dCBkb2VzIG5vdCBibG9jayBpbmRlZmluaXRlbHkgd2hlbiB0cnlpbmcKIyB0byByZWNlaXZlIGRh
dGEuCnNvY2suc2V0dGltZW91dCgwLjIpCgojIFNldCB0aGUgdGltZS10by1saXZlIGZvciBtZXNz
YWdlcyB0byAxIHNvIHRoZXkgZG8gbm90IGdvIHBhc3QgdGhlCiMgbG9jYWwgbmV0d29yayBzZWdt
ZW50Lgp0dGwgPSBzdHJ1Y3QucGFjaygnYicsIDEpCnNvY2suc2V0c29ja29wdChzb2NrZXQuSVBQ
Uk9UT19JUCwgc29ja2V0LklQX01VTFRJQ0FTVF9UVEwsIHR0bCkKCnRyeToKCiAgICAjIFNlbmQg
ZGF0YSB0byB0aGUgbXVsdGljYXN0IGdyb3VwCiAgICBwcmludCA+PnN5cy5zdGRlcnIsICdzZW5k
aW5nICIlcyInICUgbWVzc2FnZQogICAgc2VudCA9IHNvY2suc2VuZHRvKG1lc3NhZ2UsIG11bHRp
Y2FzdF9ncm91cCkKCiAgICAjIExvb2sgZm9yIHJlc3BvbnNlcyBmcm9tIGFsbCByZWNpcGllbnRz
CiAgICB3aGlsZSBUcnVlOgogICAgICAgIHByaW50ID4+c3lzLnN0ZGVyciwgJ3dhaXRpbmcgdG8g
cmVjZWl2ZScKICAgICAgICB0cnk6CiAgICAgICAgICAgIGRhdGEsIHNlcnZlciA9IHNvY2sucmVj
dmZyb20oMTYpCiAgICAgICAgZXhjZXB0IHNvY2tldC50aW1lb3V0OgogICAgICAgICAgICBwcmlu
dCA+PnN5cy5zdGRlcnIsICd0aW1lZCBvdXQsIG5vIG1vcmUgcmVzcG9uc2VzJwogICAgICAgICAg
ICBicmVhawogICAgICAgIGVsc2U6CiAgICAgICAgICAgIHByaW50ID4+c3lzLnN0ZGVyciwgJ3Jl
Y2VpdmVkICIlcyIgZnJvbSAlcycgJSAoZGF0YSwgc2VydmVyKQoKZmluYWxseToKICAgIHByaW50
ID4+c3lzLnN0ZGVyciwgJ2Nsb3Npbmcgc29ja2V0JwogICAgc29jay5jbG9zZSgpCg==
--001a1144a0e4e6d4c4052f538da9--
