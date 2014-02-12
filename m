From: Yoann Juet <yoann.juet@univ-nantes.fr>
Subject: Re: bnx2x + SR-IOV, no internal L2 switching
Date: Wed, 12 Feb 2014 16:54:56 +0100
Message-ID: <52FB9950.4000801@univ-nantes.fr>
References: <52FB7843.6050601@univ-nantes.fr> <6AE768456CEC4B4A9B2248CB6B87EB3E1BFF7EEE@SJEXCHMB05.corp.ad.broadcom.com>
Reply-To: yoann.juet@univ-nantes.fr
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms050909050000030901090406"
To: Ariel Elior <ariele@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtptls1-lmb.cpub.univ-nantes.fr ([193.52.103.110]:45972 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751735AbaBLPyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 10:54:06 -0500
In-Reply-To: <6AE768456CEC4B4A9B2248CB6B87EB3E1BFF7EEE@SJEXCHMB05.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms050909050000030901090406
Content-Type: multipart/mixed;
 boundary="------------000100020706010704050504"

This is a multi-part message in MIME format.
--------------000100020706010704050504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi Ariel,

> [Q1]: Are you attaching physical functions to VMs? I.e. are you passing=
 through PFs to the VMs, or only virtual functions?

I'm only attaching VF to the VMs.

> [Q2]: Are you using VFs only on VMs, or directly from the Hypervisor to=
o?

VF are only used on VMs.

> [Q3]: You wrote "for instance the physical ethX has an IP address". Tha=
t in itself is no problem and no surprise. You gave this as an example to=
 traffic arriving where is shouldn't. Please elaborate.

See below.

> [Q4]: Do you have vlan filters configured anywhere in your topology? Ar=
e they configured from Host or from Guest?

No, currently all my tests are conducted without vlan isolation.

> [Q5]: In the case you mentioned where you saw in a VM traffic which was=
 destined to another VM: Did both VMs contain VFs? Were the VFs created f=
rom the same Physical Function? If not, what were the BDFs pf the respect=
ive PFs? Which mac addresses did you give the VFs?

Each VMs has it's own VF from the same PF. Before starting VMs, I set=20
the MAC address of each VF with a command similar to:

"ip link set eth0 vf <vf_num> mac de:ad:be:ff:ff:<num>"

>
> [Q6]: Please isolate a specific case where switching is not behaving as=
 expected and describe it in more detail:
> Please describe the topology (which PFs are involved and which VFs. Who=
 is assigned to which VMs)

|PF| ----|VF0 de:ad:be:ff:ff:11| ---- |VM1|
       |--|VF1 de:ad:be:ff:ff:12| ---- |VM2|


----
HOST
----

the PF (eth0) and VFs attached to it (eth2 -> eth9)

# ip add
=2E...
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP=20
group default qlen 1000
     link/ether a4:1f:72:d0:b3:9f brd ff:ff:ff:ff:ff:ff
     inet 172.20.6.229/24 brd 172.20.6.255 scope global eth0
        valid_lft forever preferred_lft forever
     inet6 fe80::a61f:72ff:fed0:b39f/64 scope link
        valid_lft forever preferred_lft forever
=2E..
30: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group=20
default qlen 1000
     link/ether de:ad:be:ff:ff:11 brd ff:ff:ff:ff:ff:ff
31: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group=20
default qlen 1000
     link/ether de:ad:be:ff:ff:12 brd ff:ff:ff:ff:ff:ff
32: eth4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group=20
default qlen 1000
     link/ether de:ad:be:ff:ff:13 brd ff:ff:ff:ff:ff:ff
33: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group=20
default qlen 1000
     link/ether de:ad:be:ff:ff:14 brd ff:ff:ff:ff:ff:ff
34: eth6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group=20
default qlen 1000
     link/ether de:ad:be:ff:ff:15 brd ff:ff:ff:ff:ff:ff
35: eth7: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group=20
default qlen 1000
     link/ether de:ad:be:ff:ff:16 brd ff:ff:ff:ff:ff:ff
36: eth8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group=20
default qlen 1000
     link/ether de:ad:be:ff:ff:17 brd ff:ff:ff:ff:ff:ff
37: eth9: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group=20
default qlen 1000
     link/ether de:ad:be:ff:ff:18 brd ff:ff:ff:ff:ff:ff

# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode =

DEFAULT group default
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 promiscuity 0
2: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether a4:1f:72:d0:b3:9c brd ff:ff:ff:ff:ff:ff promiscuity 0
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP=20
mode DEFAULT group default qlen 1000
     link/ether a4:1f:72:d0:b3:9f brd ff:ff:ff:ff:ff:ff promiscuity 0
     vf 0 MAC de:ad:be:ff:ff:11, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 1 MAC de:ad:be:ff:ff:12, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 2 MAC de:ad:be:ff:ff:13, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 3 MAC de:ad:be:ff:ff:14, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 4 MAC de:ad:be:ff:ff:15, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 5 MAC de:ad:be:ff:ff:16, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 6 MAC de:ad:be:ff:ff:17, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 7 MAC de:ad:be:ff:ff:18, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
4: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN=20
mode DEFAULT group default
     link/ether 8e:31:e9:eb:89:b9 brd ff:ff:ff:ff:ff:ff promiscuity 0
     bond
32: eth4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:13 brd ff:ff:ff:ff:ff:ff promiscuity 0
33: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:14 brd ff:ff:ff:ff:ff:ff promiscuity 0
34: eth6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:15 brd ff:ff:ff:ff:ff:ff promiscuity 0
35: eth7: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:16 brd ff:ff:ff:ff:ff:ff promiscuity 0
36: eth8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:17 brd ff:ff:ff:ff:ff:ff promiscuity 0
37: eth9: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:18 brd ff:ff:ff:ff:ff:ff promiscuity 0
38: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:11 brd ff:ff:ff:ff:ff:ff promiscuity 0
39: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:12 brd ff:ff:ff:ff:ff:ff promiscuity 0

# lspci
01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet (rev 10)
01:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet (rev 10)
01:09.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet Virtual Function
01:09.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet Virtual Function
01:09.2 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet Virtual Function
01:09.3 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet Virtual Function
01:09.4 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet Virtual Function
01:09.5 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet Virtual Function
01:09.6 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet Virtual Function
01:09.7 Ethernet controller: Broadcom Corporation NetXtreme II BCM57810=20
10 Gigabit Ethernet Virtual Function

I'm using libvirt with <hostdev> XML blocks to assign VF0 to VM1 and VF1 =

to VM2 (also tried <interface type=3D'network'> and network pool, that=20
does not make a difference):

VM1 is attached to VF0:
     <hostdev mode=3D'subsystem' type=3D'pci' managed=3D'yes'>
       <source>
         <address domain=3D'0x0000' bus=3D'0x01' slot=3D'0x09' function=3D=
'0x0'/>
       </source>
     </hostdev>

VM2 is attached to VF1:
     <hostdev mode=3D'subsystem' type=3D'pci' managed=3D'yes'>
       <source>
         <address domain=3D'0x0000' bus=3D'0x01' slot=3D'0x09' function=3D=
'0x1'/>
       </source>
     </hostdev>


---------

Once VM1 and VM2 are started, we can see:

----
HOST
----

# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode =

DEFAULT group default
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00 promiscuity 0
2: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether a4:1f:72:d0:b3:9c brd ff:ff:ff:ff:ff:ff promiscuity 0
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP=20
mode DEFAULT group default qlen 1000
     link/ether a4:1f:72:d0:b3:9f brd ff:ff:ff:ff:ff:ff promiscuity 0
     vf 0 MAC 00:00:00:00:00:00, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 1 MAC 00:00:00:00:00:00, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 2 MAC de:ad:be:ff:ff:13, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 3 MAC de:ad:be:ff:ff:14, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 4 MAC de:ad:be:ff:ff:15, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 5 MAC de:ad:be:ff:ff:16, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 6 MAC de:ad:be:ff:ff:17, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
     vf 7 MAC de:ad:be:ff:ff:18, tx rate 10000 (Mbps), spoof checking=20
on, link-state auto
4: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN=20
mode DEFAULT group default
     link/ether 8e:31:e9:eb:89:b9 brd ff:ff:ff:ff:ff:ff promiscuity 0
     bond
32: eth4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:13 brd ff:ff:ff:ff:ff:ff promiscuity 0
33: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:14 brd ff:ff:ff:ff:ff:ff promiscuity 0
34: eth6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:15 brd ff:ff:ff:ff:ff:ff promiscuity 0
35: eth7: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:16 brd ff:ff:ff:ff:ff:ff promiscuity 0
36: eth8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:17 brd ff:ff:ff:ff:ff:ff promiscuity 0
37: eth9: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=20
DEFAULT group default qlen 1000
     link/ether de:ad:be:ff:ff:18 brd ff:ff:ff:ff:ff:ff promiscuity 0


---
VM1
---

# ip add
=2E..
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP=20
qlen 1000
     link/ether de:ad:be:ff:ff:11 brd ff:ff:ff:ff:ff:ff
     inet 172.20.6.221/24 brd 172.20.6.255 scope global eth0
        valid_lft forever preferred_lft forever
     inet6 fe80::dcad:beff:feff:ff11/64 scope link
        valid_lft forever preferred_lft forever

---
VM2
---

# ip add
=2E..
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP=20
qlen 1000
     link/ether de:ad:be:ff:ff:12 brd ff:ff:ff:ff:ff:ff
     inet 172.20.6.222/24 brd 172.20.6.255 scope global eth0
        valid_lft forever preferred_lft forever
     inet6 fe80::dcad:beff:feff:ff12/64 scope link
        valid_lft forever preferred_lft forever

 > Where are you sending data from (a VF, a PF, some peer on the=20
network) and where is it arriving (perhaps arriving in multiple places)
 > Please detail the behavior you expect and the behavior you observe.

When I send packets from VM1 to the default router 172.20.6.1 (this is=20
an external device) I observe that all the traffic is visible on VM2=20
(tshark listening on eth0):

vm2# tshark -i eth0 icmp
=2E..
   0.000000 172.20.6.221 -> 172.20.6.1   ICMP 98 Echo (ping) request=20
id=3D0x09ee, seq=3D1/256, ttl=3D64
   0.000297   172.20.6.1 -> 172.20.6.221 ICMP 98 Echo (ping) reply=20
id=3D0x09ee, seq=3D1/256, ttl=3D64

Same result when permuting VM1 and VM2. VM2 sees all traffic=20
received/sent to VM1.

Another test, I send packets from the outside to the PF (172.20.6.229)=20
-> VM1 and VM2 see inbound packets as well as responses from the PF.

 > Please supply:
 > Mac addresses, ip addresses and masks, configured vlans (if any),=20
promiscuous setting, etc.
 > ip -d -d link show on hypervisor and each of the VMs involved
 > ethtool -d from Hypervisor PFs
 > dmesg from hypervisor

dmesg is attached. I send to you personally the output of ethtool=20
command (>1MB).

>
> Please note we recently submitted some fixes to our tx-switching behavi=
or:
> In e8379c79 "bnx2x: fix VLAN configuration for VFs" we fixed an issue w=
here traffic with the wrong vlan could still end up in a VM configured to=
 a different vlan (hence my questions on vlans).
> In c14db202 "bnx2x: Correct default Tx switching behavior" we fixed a c=
onnectivity issue with pf to vf connectivity.
> Depending on your answers to the above, perhaps these might be relevant=
 to your case.

I don't think this is relevant for tx-switching since the issue is also=20
with VF to VF traffic + concerns RX and TX switching.

Thanks for your assistance,
Regards,
--=20
Universit=E9 de Nantes - Direction des Syst=E8mes d'Information

--------------000100020706010704050504
Content-Type: application/gzip;
 name="dmesg.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dmesg.gz"

H4sICHuW+1IAA2RtZXNnAMxcbXPiSJL+fPcrMmI/jHvXeFSld+I8MTbgbq4bmwN6dm47Oggh
lWythcRIwm3Pr7/MkgQSAmw0/nBEd2BE5lNZb09lZlXxDfClXCjy9R2GUZAFThj8GUT34N4n
8XoF6XqRvqTgrtapyP7z2ykKp0k7rtvA/xJE62d4EkkaxBGoF4xf2B0vDdZRh6n+DzhL4jj7
9XGxDkLvA5zdu+5GWLswLzic9cUicIpPHf0DfIC/MQOmozHM1gJuxAIYw39dpnRVG3qDGXCF
abt29OLl0ok8CINIdOH67m42H46uPg4uf35a4rP1n52mbWTa5devw/4lV2xu+pbe4bZidjRH
VTu24pod19IsZvmaqnkLFIcgykQ4D7Cs9SXW4I910GxxYXEFLRjeTTurJH4KPOHB6uElDVwn
hMnVCJbOqrurJMVzzW9LsQTlWdl5dWqPbM/3/e+wTp1FKE4BY7tgrsddvxUYanpNMH8hwRKR
iuRJeCfB+e4unKo7Eu6qNx6C52TOKXiqvtjB8/NXG/NEsx/EX4DzRQPObw/HSowtnMs3cPs7
9vZ3OBs8C3edCegHUuQD4IjNhJvh9OyCg+9PDbXpiKwAfmGiMNoZZRe7Iv3RsAt9EYbIJ+4F
jOMfIhl49wJGGld+Vka36m+9cyhglAuu4vT+Gb/Bea3un03rFfa92G3DsrKVSsLl5S8Hmy/H
SsQyfqpiOVus4w0Ww9XHMSySgOrix+voQAmhk2bzlR/BJRbgqvQVTvrnuZO4D5vnWlmLXYzR
bDIBT/jOOswge1khna0j13Ef9tkkhf3gGTkmcaJ7kYKISM5rMAz+Letp3+ALfiRBJjoLx31s
yl1JuWspd7hkgJ6U65lbvGL07BG1pOirRfclZF99A2SfGrAzuH7NygGZ2bm5eRVSNuWTkwRy
HL3emrBwUgFK5YWdnD4CGW+VT45Vlm0RrAZC7y0IfIvQayDcvAVB3SBsKGSLoLwFQdsg8AbC
4E0I+gZBayD03oRgbBCslgjmBqHXQHhbX1jg5STaIAUA++B3z5YB46vZZpyRmwXKOcShhxxh
YosYKCffzyESP+RDVjzE97fQpVeYjxTn76wJb6DLOpnRkn8Cl0mSlL7caNzJZIlOVqFeX5is
pF78E+1C52iFZEZSZKiVd6iU+95YDqnLECtOXiBLnOUqJu9vV9e2pLB8gzT4UwDXdLPRcl9T
8nk/XsPKoYnvxwl2WoI8IU3C73YVAvSV53np80KkscpXV5XGsDgiK40ArTHMrief4RvKMdPz
8cE5FH9LnfHH2dX1l8FhHelyFDpCeaMOq+iwYzrH2gOdEVFWcuuYHGqR/dJ5m/DREVt5xVbe
3lZXqZTuvWbrPulDth4ttzIQXL54rY32SrcptxITbGKBw2O1Ej+w42N1q8NLHfW1vix1tG3l
FnUd9vG1FpH1YG8rByvcqPuh+hxrw6r/XRp8uBX3Sx+qH4aM/eH086Ys1dAcp2hPk2vuvpIo
XOrCZNofVx0Un+maIldqDc6eFA79wZcvAB/2a/8+7c/q2oZl0YMrqc0KbRgP5tOeWvqXSvlF
+ekA+g2+bdAxVFN1VXPpwY1EV/8aer9qexlYgmLc9Hqv2D68nX2hBANTODti+7RmuynRyX/Z
r3A1HvZqCppmUlOywdU7NOV03JvU0Q1Dowe68g7on8aD2Q76Qg4D1XoH9P7oatd2n2zHKfIO
6KPezcc6usNkR6mvDYO3oP+zP5/voOuEztT3mCDTL7tjZpFPP/4e6IPJtNarisosmn7cfJcx
M9hFV31C1/X3aPfrwaSOjtNbUof6HrYPhrf/vYMubWf2e6DPeuOrOu1xIeeqUaPklujj3s6I
1LmZow/eY0ROrnaYwFvQeNd679Ey0zplq6r01xWuXhVjBpl5gPDj8QgmvREGXCV6QdmKgaRt
H0D/ElP2VfKw43kY8aS4kvoidzMbKS6sKDbm7yMM0Tu/FOyNfgx9uI09DBMPa/CKBt9qsDeW
wU8ug59chnZyGdrJZRgnl2G8VkaOVhTVjJ2Mg2FFRZ0V5RbqhrrVPxyW0KYIyaciW68gys04
xQCA27v+YN6/ml1tSibhxWuKe0pmp9m+p2gpbFcUvf2+KuEJR9m8OuUDZi0Kj3U86lOvldG2
UYSYuSg92AZEcVS03OGCcAWqF6QqBwpymWnUCsJ66DsFNUbRv+KoTOvtSeehIwLyVelYphSR
zsHGRS2VV7XYpk8ORwE4FJMlstHeeOBwV47iJ5lA+ZPqkWZOkskkhXDcB1njXfmBk4QvZXpE
Nkle+aY98kt81N1b+WKv6U1qb4gkm2rV6h+bRIUi6542Be7KkQdZnDmhTO90weCmbVr2/oFA
TYwiWpELWqfCk22NxWLkd0yHs0LnUFKtKqzatpmLn8OX4c0dLJzMfeg2p0gxznItpiqGdYJl
G0VLxQbT9hSoNubKZowWmppt87cWWdPUNdXWLOtNhZYdxXY6ymaa3kjX7ZRjW5uqnWhhgf8m
Cwsva9SZBUuRwPAOxnGSdXEoWor1Do5HoSKlzxx3FcwDT6a2vkPorAK3+Ei52TxffMjbaSDw
GgJvgaDWbeCnI2h1G1og6HUbtNMRjLoNLRDMug3G6QhW3YYWCHYNQUPAcn/hzRBOHcJuAbGo
QzgtINw6xKIFhFeHcFtAiDqE1wLCr0OI0yGYUofwW0DUeUJXWkDUiUJnLSDqTKHzFhB1qtDV
FhB1rtC1FhB1stD1FhB1ttCNFhB1utDNFhB1vtBb8AWr84Xegi9YnS/0FnzB6nyht+ALVucL
vQVfsDpf6C34gtX5Qm/BF7zOF3oLvuB1vjBa8AWv84XRgi94nS+MFnzB63xhtOALXucLowVf
8DpfGC34gtf5wmjBF7zOF0YLvuB1vjBa8AWv84XRgi94nS+MFnzB63xhtOALXucLowVf8Dpf
GC34gtf5wmjBF2qdL4w38sX8djSswlCK5SG4fwBBh+DCIMqIzr4fgBje5WZs4pYiBiIg4Rai
92kwp9M335QmTA6A33ShsJ1Ox2yOG/PzWlSVI57Dx+kQlA5vHCbcZxTbMUr160ap/KBVrGIV
O2KV6m+sUnlH199iFt8xy9wxCwnqkFm8YhY/Ypa5NcvQOpZ5wKzb2Xw66c3vfpvA2WKd0sG3
dToPkj/wr/swXjih/MDB80P6f2goHMaxqzh2PrxC8SQOQk3+R8mj/MULxFi/JPBE4xTqRpaf
IGu/LpsfFJIHks9GV/3ZB5lrmI7G4MaRH9yvE4fOz0IQ+ZRnoL+P7KwGXpE+MBxTyU8EdmX3
5Ke2djXT5WoRx1kXNAvGSexiZ8ZJCuLZFcJL4XYy742/TnFeLoMMYh87/SDCVRjGP6gqKgdU
Ss+Ba/AQZ6twfS8f7GpGCXVQOscx2AWmNI7gj0ddmIj7IM1Egm0YxanzVJ7PqqYWbUp+HDsZ
9SagyunzzanztkDlufPNefOWQJsD5+6hZOSbgCoH9ry/BFQ5sy7+EpC/BSoy+m2BtsfeDybI
awfc97UFOE9OEMpkOE29cW8InngK3GZu+xpHOg3xlZM4T0GSreluCxr3KJJIhLRXsHASAQ9O
4v3APxpzhfZd5iuRuKt1t5xcXZwvOBXwER0QnS+CLN0+Qs4tP1EuU35sTMHxYIJAXRgsF8Kj
6yG8SAP/TKc/f93upuTrGaRyqxMSi9nIspxr+GHNVKaYDegVInQcnNlu95gaSJFL9neu2CbT
j8Lg4gtyJxYUDRQDFAsnPzAOTANmALOAK8A5sQc3gFugKnAUD1dcZDpFBUUHxQTFlhd8VGA6
MBOYTUl0rgLXqV24DSpr4F2vgzCDPLEd4ohLkW3zDZ448URyDst4EYRB9gLyDhMNgTi6AJhR
YhmKzDLjqqmZdiO1PI7DwH0p0sN5rnhX5HM+ftz/N5eOhiTTGd6NRjiuinRio17DPo709AHy
g7giypKA2kFTbAPOZMN1QT3H9cA0LFwCM5E2FuBnmtSbEvBj5mRivniic8nn4EbZc5afsUWH
s3kaqvcg3EfqDAfnVLZOxMVFY3l9wy2LUcEpmq0phm5Zn3/WFW5ptqV8rlDDmaaq7HM51V2c
jeega/ZnSH7QRaJzHHI2x09x/slm+IHO+J3TRslnWKS4IlqmlQsVuzmN9ph++XqNK/k/kVfu
o0tDO4c7asdLpYMNOQqiu8W/hZull+hn0ZJ6SU4Y7USnl4059ykQCZ2qzu+J9b5CsFyFYond
JH2IRkP9x53vh7HjSVnUCelcegp+Ei9peu9dwo/pkDy6Hh2VNfvkbv7pX124WSOs9xJlASnl
8myv/GSOvtS0q6k6L92GLqeTS6wx23pxlMYhjik3DuN1Ar99vPoHWBSQ70q6uSR8y7KX7QbG
rpRkGRyUHp3iU7mhI/nJsUzuEM38eX6vsUFRoaDj5FnyAj/lEvMiPrrM17CfIF7ljp0PL/Ea
vDj6KYMfTpSVm6y5WqPRB2SoHPXrLCaH0IXbr6MrXHpCJ3LxiwtqBOk5CvgRZA8Q4dIy33x9
iaQG6UvqZg0eeliJDFys8CO6y2hIsll/dyWzFKn3xkkzmE171PXBovBT19KfHQ9nGxVWUekL
uitDrckV/MpSYfTpT7omlrue1WIo/dwrgRHSE6HzAmEcr+AsfQzoXP8HDEeccC3IAHcdym7K
y8/kjpqfiD/WInJfLi5Aw/XqAheY6/g+Hg3HUzgLV/++JDPQCqU2EynlvAq8+dJ57pZXp7oF
jy1xTi/XS/yo1PbzLANnr3DXCa0SN4mzFD/i5FEyQJB7CVVpm+b6QF527UJ5XU5eUyBnujIB
NM2yv2OrRTSQ6FaS2Mu5lmpZBq6kJe0yZA7DZAo+1Xapl1k2ZbSG5FB0DkNqzNZoE3QDSVSu
6rqmqXwXkuuKqdGRgnWUHYHklX1XrquUIztyQ9gTi/V9Td46Kp/PmqqC9loBdSePNMyjGjie
xJ8iqWnYRzUikc3dsFaGrhzVWISPQVyTZ0flcenz53K61pSOV/1hfS+ycFHVsFFDupHj8nLx
JiCEYb9bOWlDwkYpvJHpxUg3u4IaJR6WLtIxSmPhq1WcoHeF03DUGyBjRY/VptEoU4iC6K7P
HoTcVF/GWIk4oRqUTsLZbMSqQ0+jLvhCVCSDfAhmX64rw/jzNegMl0k+uqZcj0ZvR7S9w9q0
2GryfVcfm3Luh+v0AVeLefoQ+EgXekVIt7DPb3DwUD0otHdCZNXIoQux6SamYegmnJVhjMVM
efsMOlB9RC58pfKGTTvGefwvOyDBMS3TM7RaoWdescJSTXtzghxXXplymFGbptgzLnWjjyvy
Czgu+oRVzuc2csF38JYO8sCnGNuqTPz8CDxcXzSjJmqUov3Jp/4mBZGvHF5xxgb80LlP5fOK
LqfhkutK3xPk/dp7maKaU5mw0X9CemddBTlxhcGIYlouUwxf0QwOgp75Cld8UcPWjtnlsx27
WE3XrtvFGnaV+qfbRTu1OfZkNJns2OX6mi6HgYi82lODRkQNhr8Co+yD0ZVdGPUVGL4Xhu/C
bBr7ajad7O9t9OjLJCNQbhHQN8fW2/QOULxe9ncxHmrqrKqu7FUvu6Xotpq6WlVnJ6tjDYuU
256yt7o1HeTY/yWvVF5WD5Dsk/hRREBBn3RVUvJgsgf0A5455VxhITZp9YtdpNlDQDMQp3KK
4cJDhlPXE24i/U5aFSjUjFzR0PuK3/+EUWAils7qMorneVlz9EfjdfYTZPEmW5kbWphWBbJo
p25QMDI65yDBZGSMofOztH1ZPUVIKtjgRbWiOCv5/HxXPT2CgMvzFF1adDC8/BAULmrSOUSb
Nz+KgYOtYiv6MDaqXVzMhqPBpIsT1MUF5ZJ2MGRam10q6OxF7JLLj/yyw+gzvZcYyKQaeaOb
XGe+Rskg+WzyAX4XcUTvtMYNMP7WKA0BvwK/4MpHdG/PfAcdRrpySxUK0RHCWmNXF5e+FPND
tSRyi8ip9oTjyQuouS+7E5+QpIoO0Xjb0TAgLwCn2XhwPQV/mbF/YFRqdDwhVvDlenIOUxxo
L9d5KCxdBoxJifM7OY+75L+JBB/KqsEYx7yX4BqVXFSL1QxqzotyJ6ALOy+1Jmzmwosgy1eL
HXHNqklbufS9iESCA6AMQNJCqy5sF3bIEICyZ3Vsmn1+5VXVJaeKdNHFp7kSxN4JujzXlb+T
0Fmtk1Wclu3Z3a0/HTYh4Tyg2m+kQrevlbzIrS7TjWp+vcw93hbHVs+rCXv4Gz2Cu8+lusoU
XWGH1ZWmOq+qc41bp5WuVtVV06STbSeUrlXVdaaQr3JC6XpV3cijphNKN6rqpmnpR4zfU7pZ
VbcZo/DuGqkJSRnQ6bZqyRMpoFXw8yxi7KPcagssfy5FRrRnKi666gXyVRm7bvhCU3Sd+AJD
mWy58nH47Qk4NcVgqkYhbeRmCeWuElET3HyTRweZWFZUOa3St4NZLRtPv3kRuzFyrbMMcN3Z
5mEohUZ7w+5qHXiUh8nj8XtaUSIME0J0l7YRlJRmh6WXIlpXZfVitwturvozWu1CB/1QXDEF
5IaDF4uUEilFrEHZfAFX0/EIGTcu11IIshoqL/1i2kik30iRmwDN7AcKGxTo47ddGI16d7c3
w4/53f546eCyJZ2Fb3I7ki4TfK/8PMG+zRM4K5yF8ssPtZLs3ZJeQSvTirSADiy+cT0wlDdZ
CZbvN9b3FmWVmayINMiR0UBF3SYykOryd3imRVsXyZzzfHGSOyNucLnwcQBvV2ANPW/yKpdZ
gu7gC7k/NB3gwSFDKQtHrYzkuPmxFPnTKanIaNalNRithMEBuEDZlxxPeinU89KxyK+3lDnL
uh16CYCTIMkzUbWmqEhjwIRdvQhiFEanKsMhFjoL+C980lF+ob7YNjBXGZ3NK4IruQkzv5sO
z0axt8YK9WWm4UNN3Nojvo2m92hwZY+GeqHAfNobw+AZ25CW47SuxI4Wc3V/j6PcyfaWaCob
5UGPjp7Hj8Rmgx6NL7oSvZXVDKrPt5sgWdLGF1yv7793y/uV1DmyXJnv+gDoTCYv/8fatT63
kRv5f2Uu9yGST5IHb0BX+8G2vFlVVl7F8iapcrZUQ3Io8SyRCkn58d9fN+aFF4czVKqSWllC
/6YBNBoNoB/Z4g4WuLO0qCSkXYdof6yf1iBfkeFjG9ZjDb2elk9Veqk3728//Pbp9ufffv9w
cZL9436BN09oGlS3hzcPaAXdbG0ik3/d3pBbWH3NIfn1/bfv82JangpFjt0PNcP3gg/RYR/i
L/4QG/Qh1o7xUXsdc5NnNzy7EX5D1jSsNEZ9VEIdgS9I6/Xz07Yxv1061BQYsHte3S3gW6ml
vy/guFOWS3fjOfMImaeh7vGeoX62+bZYzlbf6ocFZOp/8dZ8WaIUF+sfJ+hlkf0Jdc9yNV1v
/lQfqOwGUGTONSJ8x9o1Vcc+wIawmn5pLgKr16GOJ8kNHpeaWNjL7CNs11ltPn+GXwDQUUrx
s1nnTMOlIAx0L7o8ZdcfrvM3uT7Pc9xN7aGqdf6AFfIOddF2DdvqEXocuxjMevCEGLsIs7t1
AXPUrRkpGRN2eL1xhVNTxTKAdSdV29rgK+vi1vnzuX1rtASw0YDahROH02OXGk/mQ6gXq6y+
RUD/DVbMfRQ2CoWVFmU6Vz4KH4cyqXiZBbzIUSgz2yPiuiNYFD0GpfZrmYcoIh+GkspIN4nR
6Bi0mW7tjsiXxKINHO3GfWPGazT8kYdo6G0KaC0SPhmdZ5/RvemcTe2jElousPTAELR+aDaV
lSvJ9jgdY1xfvf/vxkbE8C5ULBd5dsHugdULBqatu3gE4QEI8RihDSPEZYR7jAilUxjjGJGK
BiDMY0QPYEQxmcIYx4imJAARLiNUJ6bGJtByMKx2DTCog1Hsx4BTZu5jEGdmyIyV+wdEEWFS
GKMGBLbcYGaI9BhJdUYFnaGKpTDAQrNhrZ0T0zxvgr3rH+eZ5JPF1lk8ijGdAhvXK2swByDE
6dVkQK844ymMZK+mXa+myV5xE86VBRvXK2HCcS7cuUIf7ahX05xRt1cyVAkVRrJXs65XM+ap
OKXycICL8bOkdAgydftD8gGLQMtwTKbjGTHRIpieKYeRAatR5yxc0RZjFCOaRHI782ZY7p9h
TUI9WWEkZ7jsZrj0Z1hTqlIw4/rD8pCXsusP5XzXwBIHg9NwcubumKDNlthNiTc5UnudIc2O
THjJYSnqMoFB/R1Z22NljBGPq+lMDaOsqVHpA0wU7A2xIn2I2kHUHeK8F5H2ILrupJPKqfK0
+rEX0exGZA5il/8PfrTdjrGkSGGNEyll+gYNptPpI+/6yNXuPuo8KR015NyDnHWQNrveLkgt
I0gyUuC00SmMWOCKbuiLXoEzeTyZJCVwRSdwRa/AGdKD6Atc2Y1c2YdIkyN3kMAZSVNY4wTO
aNYzaL7A6a6PukfgjOmbB1/g5h3kfKfAGa5CY7A20+Hk3B2aq2Mv8ehUaFVbusy/wkgOugqO
UQCmQ+u6F8xRlJMeuTVci2CTr03/ROeoS2d40spO0TGHTuTc+x5vt4sKBs3daPUSzx4ADElS
GM7qrU7LaDDiOXLqDaXIdd5D7kjITLXW58wdRA/Ml7cAbOqCtRI8U5M0GKHJwUks0E6JTDVJ
LFDA8lVcg9Xe8F2Q7KL1WhKUB7tRa+0lJpT/4dJFNtE0KZj1lOTxBQaCJKzEvqXSdX8WLBUB
p67cs8NFK2KG0PPKlbPf5BRUSaZSGCPUmxDo+Z+0WxNDKk5h/3BIdZ40m3cNyKwbkDK4grFg
4bmvF8y5z9G7dyghpJTeQpLjB1oY7s+8PGCgZS5yFoCQkYxIxnyLUY6/jBFSKEGSYpOYcenN
uISRSErtITMO8+JvPfvABs44nMR8Y1+FM7731ksoYng40DvHSJ2C5HaklAiVIh0yRqGaUJT5
q2If2MAxUpz4E6m7HY5OYCrw6iPa4axLm4Mh/ROijne43VyF/IDZ14PlbHdlt93FwyWI6INx
DFxn1MNAPqEM1TQlQanZd6ceN/0U3UFTb6S/TPeBDZx6TSTlSR2S6Jxx6eAgnqLbxU853732
8V4g1PblLiaKP/DJb7JdV4V40HtiNesefBFMhVcVZc/uXnNln232I4f2Ri+y85SzFzk0lfcg
d887+5HDG7FeZOfJZz9yeHfYh+w+A+1HTt4T7ZCtPPE0tP8LSYEbsJo6p5c9XzDhYaPvC6kn
pH1fYCL1DrdaVnFUdXbHo6fvjxnxyNACit5gq+Ad+4x7c32VHVnPJGBxgVFjmwwUx2KTPS9b
q8JB5EzIvvdlknpf5vmpKv9wUawHmM8XGfW+DBj2Yi/CGPq+LLRovJV2vi934ZvY2oSvjnz3
+3LVY486fGXcQV0tIJq31SJ8FDEGhVcoIkJRY1BkhaIilPC9vRdFVygmQFF5+DLci1JXfZhE
KAPnpkKZdsvbRxk4R3Fcvoq2OTAkXa3Dxz83Aob2LiP4+OdGwDAy1Bw81Byk0hz02CVTkeYg
L9IcMu/cc2LNkb9Nag42d9WGJCZa8nSk2pBWk0YYw9WGtI+DfWqDzb3W4WJj851qg7kSJDl3
d0Ygy7UrQTrlSxDMvhSexYcYxsUwQzBkngcYhYsxHYTh+UVUGMTBSL3khBiKsQjDWQ1TOgTD
uw6rMFiHMRvSF+0ZsIgxccejHIJhGI0wHD7K1DVjgAGqkwQYU4+PARpG5TKUsak7L4MwSDQv
0zPZYcxTB8oIw4Ty4TzDAkbq9TPEoDIc09no8WA0HI/Z6PFgJubDHQ8xAMO/dkKM0u1LMUDG
4Egcynrp9oUnxpQQ9/UUMUwoY3OPjyHjIVWM4fChBqx9pUSog+bu2i8G7IRK01DG5u6aK1Ke
ISGG/4xWYXAHYzoEw4TrZX4mHIyUL0eAoXMVYzgyVqQeGUMM/yIIMIjnqzYZIGOasjzCcOZ2
MmBuNSMxhjO3kwF6XbNQTgHDmdvJAH2qudIRhjMvkwHrVgsRYzjzMhmgx8BEiTEcXThRAzAU
DcfUc/+bDFi3IKiBjBHPc68coNehMyrCcHVQYl5CHaSjvRIwnDVXDtBjOlpzgOHMLU/0JcQw
uTARhjO3fIB8GMJCP2M0B/ed443dYiOj9QXWuCGa77bGSdoaV541bmwiCZ8pNtIax/fJBMZw
a9wIyfqtcTX3WocHaLXbGleuNW6Ecj1Y1CHWeHCvqw6xxo2iOsAYbY0bZXiEMdIaN9pbDeoQ
a9wYGo7paGvcGM/aUgdY4wbLskUY46xxkxMazu1YaxwwdMjHWGvc5L5XrzrAGjc5IzLCGGeN
A4Z3M68OsMZNznk4HmOtcVDaJOZjnDUOGNG8jLXGTe4/RqsDrHEDRl+49sda4ybXkZyOtcbB
Bvbes9UB1jhg6FB/jLXGDeZxjDDGWeOGEBHOy1hr3BDK4jEdZ43DDh+O6WhrHDDCMR1tjRvC
FYkwxlnjhgjBI4xx1rghksUY46xxQ1Sox0Zb44BhVIQxzhoHW0uHfRlrjRtiwv12tDWOuYrC
uR1rjQOG1hHGOGvcUCJijHHWuKGUhmM61ho3rYuFbw7uuRsHMhLdjbOXWOOAqI1rjV+20aq/
LpZfss+//hWvYI8uP/5tk7GMZyKTmbI5Y3n2yjWoDeVNvoGdSKRDeuVD+Ugi13uQ6C6e0FR/
lZ/EeYAQVvI9sCyGfZViUNJ9XeUu0qvdXZVK7kESh3RVMbIHVvqwr3YxqPQ+BlWSwVcRku7O
fU0uJJb95fq9TWE0wTyauGLgAMV+dqlM+3bzr9ubt7dnGEp8jqkLFvMf2X2xnD2U6yoP0mZb
PDix70DsJHxriclgYpIHxPnbEcQ8ICYjiFG8fsb4ahhRu9rtOTFIwSgMo7hjfr0rivXkvP4z
ZpsrZ3ayzq1eqf2RTqqX/c1Pi9X/PJaPJ6tvy/ZnHPvNT8vVsnSx0R2pwca8tS6L8FfW/bU+
+zYn5qfVZrPAaHb3+y6tyaMUIr/fvE2kEIHGNgz4eTOp8rCsnRzn5bcqth4j9+vMS9hw7g4Q
w6PzYOr754lDy/GicxdtPdjdZx1Chc5+TnC+vVPAVAA2d5efBEDAIVI26UJwP7AJQW8xldWt
zeW8Kbe4JprMpA6dQm/BKl97ncsk+/jmCoZ0PgeWkin/jf9UjBhsP4ab7T8MYwYMg768mAwX
QIptdnV1+VvWFVGwGcs2WAtDn2AyIe9/DYqNQ6Ytisbk3pg2frvC/FqSn6JLGeFnjGiic5sF
t06/1SFQ69nZJjyDMbO5eetrFUTu2nJjTc3lE6yT5XU1QZhpwW1hdJzn5sN1QkhljhmHLFxW
e8d8nj0WWecLDi2YjbHrWlxjoQdMvHCNeXotA5VIwXhdbOzuTkEbHlVuOccOErfvZjUSGYQ0
xcy0MZLEh/Y6ExCC0YFgJAVWuWXXbLFBSJNkB6VNCNUg8UFIIsmTFPYFvEYSL0BSBDd0Z6hk
G0mBeUdxcWk1xyzZzw8zm1ZnUkZVaC2M2QmjKxhb46fJ/pGCQJftNISpODFkL4TcCUErCIy2
6IWg+W4Ivo9W7KJlqnI4xAucfgi9C2JaVN6QxT4ItJB2QZgKYrIPYmdH4PBeQeybCra7I5Xz
5XSyD4JHAnHwKlY2AYgDptwu6X5G7E69i3a6h1awkHZPJy6vL2HPIH2dMcSfn84T200Ixsra
07KPP0NJCDVokGmCL22TxDlgpuOLd3w1jl19fAGUCKEO54vnPljR8cXm3XgN4YuTPIQ6nC+h
fK05caLJ26Ln+GPlT7xHCaNvWwh3OG9K+0LvhLWxdi7xx2G82YdPH+5w3gx3LIXZICSSswSS
ITo0l86r/E94XgyOJbY5S9pOz8uE9URBB3o+zE1gapM2e/OEJvp09fCwqDKo7ovFtUnqHhbT
7aaq6ODA5oMDeSWl3I9ZaPh6++ZjBkq2gEPO3RIszTZqtkOc7EQ8IF4W6ViY2+fQeFkE42wM
2LB4WcQVQXDBkHhZpJOhG/6AeFmki0IOBoRlWro45m9cWCaCJAIYDwvLBDDhR8gPi/wBOuld
dr8k8gfAFNdjwIZF/gCu8cVtcFCbpGGAxguC2gCM+FrmPxPUBrhMHRDZBHTC89J+SWQTgPnO
LsOjK4HUmCTpAdGVmP3Wj2H7z0RXAi7znIrywfHClnRUiG9//1iUnuk/EC+MuKFO7otMc+lE
MvVg40zC+7IGIrlMZg1syEVfukBLnkz015DLvjyBlryXedWXIBDJVTIZX0Ou+zIDWvJe5s2Q
lIAWprcTJO+L7nJxdG9vCBmSBtDiRN0iLs4wI4EzE+VNdGHoaPMAEKNsh9xBzPs3XCAPoxk8
cjJsq+U8j7JtiiRMvx7gUcCOB0PHawAePQjiSX48YyTqn3whYyR0XMPT+R7GEgNPov6pFzJG
oxWjD2GMRv3TL2UsUgkmyVjvng5meqScixG6nbNIERQjdDuPk9oWI3Q7j/PRFiN0O49TyBYj
dDuPs74WB+h2Lno7MVi3c9Hbm8G6nctwcfPkbp+K4bTkySjDSCJSwZuWPBm8GUlEKmoTyVUv
86ovXNOS9zKv++I0LXkv86YvQBPJdTJYNCEJeScJYWgm4AgzoD4E7QjwAfyP7NO766zcYH3A
xQbftlLlAgUWIXFqGpKTts6hX39QUk3xeh9BJ2CuJtGkEKyrS6tPsOS4FkrGWFxWDJ5nv7Q4
m7ZMABbkcDmvubTftd9woexzjYVal8tV6qWNwjkHazJdXCe5ropODuDa2KT4AHP662KbLr84
HEuiZ/femh8tAWfETybY5AvByinZ18WsXNVXag6J3evsG/G7X2/ax+CTpt4m/MZpbP1OP61/
1KWenpdPxfSLdSGYb7LFYwGniWJj3zvXxeN809YBJmdYlRf9gZrqe7bNrKu5x4zkddk9dGhi
khe43uqye/ZXinJcA8cOJMfop7okmXMx2tQv+dtz+WzLcHwtHhYzW1jCIzYNMXFufAcSY/aQ
ujDzTVUiw1ZqO3fbCBO1gUlYbrE26SMWocOKJdVzfzVhVVbS7DM+h9cl3k6z+h/derfgAo2n
seBFB5674HkIjpvkC8C1Ay7nIbitpHn4sOwB7zi/XpdPWAUjPyXyavEWxLX+gi1whl/59fqd
SysPmK95xVjFkaeWLaYklQvG6cXVG6dU2d+bqvVV4ZdP5fR+uXpY3f2w37hY1DVRLl//1mLB
PoNPRcXzbLF1ygYhk8ty+4A+UxusGLzNjhq/rWOXWNSOsj9ZsbIwR7gqCagjKbFI1jk5ThQu
AmpBbIjgZPWM5c2eVqB80IPkHNWFrbrutkQV8cvzXYkFPB3XFppdvbWNLekJmranXVHnPMSB
D8Ku/Pefb6wP4pfs38+rLaiWGf73Vp6JM+q0pWhRXuCfeqreCkJrpWvrj2J1dFfhWiCODziP
m7vH5aJ7hKr9ZKzabtvKKm3iW+tc9lD8ANSbdzeXbcW0o8nm7rhx4qkrtIEO5bW/U3b0WPwf
zDQV9NjBJGiGgbmwQUeTZ/TjWmKd5XC/qtvyoG1bqc4Z9qNaj7tf0aQ63lSFORpJri4JF+t/
w34krRhe3Vy+hv+f/rOjJbTOcBjQso5W7aRV9bW6T0uc7+pdtJTWURMB7bSjNTtpm7zEEa2q
acHI2kGLqjCibe4e69nFItjWggNBuX0scOBPsChdttj+V4ckRX2dkxr1m8XdsrButtdX77Pt
va1ZVtXMwl+0hV5cuEQa10ORkhlqD0Gqw5bK26fH0u8i/hbvefBd0nFvaxu7boAWS5LUhFeC
dgBrsr7mDVhjB7HGk/J06ExKrhKskcNGTSWX2PRQ1vyUhvxwIZN1frCgk9NDOtlkLk+t5wNY
U3k8ZuLwnqo6aZ4LJ18Cl3w8OwTJC0lvDwcHIcUjJg9XZU1WoUg21GjZgMGHTuJHHm6rSoZX
/3hz+clWVMQKXbb4MSWkqTBQ01Cf5itu1LZGLLa+8Jpyv+mDLdlrS8PerssHWzjvtvpUaw82
1UQtAkM/jPcfsTDX+/Uadp2P5RSsEjA41wvHILS2yxG2O25rKC42iaJdFtTWd3/abK0/sXNW
BLtjiyeyJzRAqup+tlE2gXNbuXQHTuCcVkzAoZSK/DXBOo/1iIPBlNkUxlWZ4M194daCb2G0
JnixVV+hb7c/bnJ03AUzNsNLIzj14n77U8ZPbIHD2wmYofBPQvCsc4wdLDL72TcNJIbm8BpS
VJCkg6QdJBsOSXJbasaWwcuKu6e7Age3ddmG2Sc561pz60o3Wc/OUSawjqAvddDCXns8lotb
V35tnZeL2pu7Lod5X3wtM3ugzGAxXDbf9KDUDqh27isRmReLB0cKgFThmXShc47uth+ubWG1
65vXtHGfRxuxqq2GlVMntk6kTUs9s+eNhx81GIXzQm4TJG03U5Sn+QK9UbAYsuv4PAVeJlW5
xvOMEmPOjDHoQd2gUEEU9qZmCbgJGelaUpvl9nH1vCnhhHVe8W3/2Zy4pqvHR+w2LBmsKfnY
XmNYcorHjvV2ejt9XG0aT+GPn4DjYpl9K76UVRbhG+7Q2INoSAP/ziK//LYRrCX4OXdB0A4L
QYqHYv24wSqNWMQbLPJZ8eMk+8G+nGSU0+rckS2/rovHE+s/jmboxgFVtiR7Vfz51GqTRvO5
574zl8Keey3FU0XQjLWtbT19es5crhXeefY3J25zvbc5dZujHdjfnDnNNW5x/c3dadNkb1eF
2xxfYfqbS7c524uuuuYsN6y+WZw+T5xK2eXMa6QG3OO5sNYX+6/lj8rDbbbc3OKN8ANKQOoL
lXeEI7BwVv6C3G/as6czndqGXIcyWxd6bXwE7UpH8aU54ac5PbUhXGiAcJX9Dguruzxo6qYj
thGoN5pbvuclrufsS7lewng2l32G0Pqqz97tYQbf7qqv+pVC5/e8w1VMidYdcnb6DDph9hkF
AfjegvrGjzU9pXkrLSzPKd7yTZbf6fdzrAVdzECPZB/K7T+36xJU7OVlJpQi318Lpb9/h2Pk
a5qf/mVxV+Dz2/vtPXK+zS6qxWdhQNcqfUbUaV6V+Xyd89eEHDufFHilX7X1D2ePGzgVTosn
AH/AOyVPB7KcULGD8Al3qOXz4wSYYIZf4LXtKYN9iSkmTlnOiOAsP+UKfsw7QMrwArm8h7Pp
/RS2LwyFomd59uf3y3usVD/7c/YLZhh516nlo/e/vLs8rjvsINknGkQ6BdsLTBdoZX1Inh6K
LRa+r/VTS0FgzwWRtHcibTnr+HLJtjQovI/lXbEp0D6TZwp7DXtefrqekuym2J5lb57vzjIG
IqjsuS3Pri8+oWi2eoSBLKI+b3j07iU76QZ2y+UU1hVabFX4k4uAem4Hgu1yMFwOqS3guIMU
w7pw7Kt0LM0iPekcPfEP9fQSF9Md9ABzVk6eq/27U70M9ZfZSVLdjdkbIhsAtsJnZrSQbLXm
JoTXAWP5bjC0uigYXYtV5ldYc+kxWVs3sd+reiPf8ersHP9FNf5nLmjlzcv/n7dr4Y0iV9Z/
pe+RrgS6TKf9tkcLOiE8NmcJcAiwe4VWUWdmQkYkmew8YLm//lbZ7teMu+Oex9nVAmG7Prur
7XJ95XJ5uLiBnmTDq9XdKKkDCedfeaBXv0OP8ZAdmNN8/DOxZrr+NJoKfHqeT8cXILJGX13M
h4RiPk5esU75L4vRYpr9aTtSXO3xS/YMsf4AKzQCD/vJuzurZ7z5epj8op89OVnN5+h/24d+
Ic/K9njGdPtnLqastXI4ZuwwBKaV1QDshvxqcYn/AVl664ebd5yslYEPNf4MHv9s/pSM5SX+
CD7geDVaPoX2aAPMdIAtluj4wzudXc2fwucvQOgTTx7e2mH8lNQRMV5SIXqRB2YUitG62Fl+
twJfebma47aZc95ZSmhqBuPFdHU3IOzqR2nsGji8jlPv5rCh7ZqM3Xm7Xl0mZAD/r/gQ+BdN
mw1P4mBpPEkLr9pfy149jCM+9KXHsRYKELhoRejWJ1hk1irax0LROqZq707QQnGRdYj0tFAA
ZoIGe1xaKLpmoSZ1CyUzQVpWXGcjaIuNQEHTJcjaBXEItAvydkGc5O2Col0Qx3+7YDDW7wRx
SWsXDAb6naDs1Gowyu8FO5UTDPE7QRxUrYI0GN93gkjf2gXbFglJGGmfTRFGGwAEK80S3c1o
I5joAOtvtBFR1RHjjDaK6brYlkYbcHAIVTgtRnuc1jVqMzA3viV5yO+W1F5WFBLczu/Wma2W
i4sC7V4+dMbJ+pNtywenbp0P9dMN1hZrhYI8ND1KwRZrhYKiRTNOsMVaoWDQBJSCLdbKCoZM
QCnYYq1QUHUqp8VaoaAO2cdSsMVaoaBpGW9OsMVaWcHQ4lEIshZrBYL2Qp52wRZrJZAFVxTr
AlnYxe0V0LirHxd+Vb2YTiaTp7hHoHXlcFhJUXO9T9+efkzycX6/xP3msqwHtYX+mOp0m2ss
E6Ma0OmzD3VxjGBZzzoBSwG08fz43IZ0x8kZgH44Pn2xRjKxKBcSAxQC1uD+9ckTg+PRCI/4
4T/HH4/t78kZkSfnL8hAZJ9OPg9eJEnGlEne/xssSnL89vx0WAWOsIAOWsASm+wPG28NwEsv
nHUeYEIKWrXV5DsQhGEVsUmzlNVkBEZt1mSms9HyZpjwlAJdHtifXFRikOkBlvEpGPcCK7eM
bwcgP7n5J/h218CqR7PbEp8wW062fF9G8YVf3o1uZguw3knxz4v3/g/P3xP6+n+S6h9c31pe
mMK/lTJp24d68fLNG/uH9y8/nCS/MpIV2BTWjBZscMGxkuFiXCF/WYzzPxMj7dWkFDM/Bhhy
TW5mX6ej/MaVBILR/IiblCWvnx9x0F7yevr8cQ3VoD3ZRP19jnl9sByidUbXdFZs7zgp9Cc2
pc6w7Nb55G4Bw55cwcTAxM5MV4KUkuBLuOasXzws6zE9AR89H2/+bXXP5Pt39jjuq0/HVRPC
bqlDG/kQfyH4C8VfGP7CqweB/AT7crxc5rYCio3qQLPfShmZEeIXbDIgjk9cT79eDxb3ExCo
+SIFifBZdoUHVSApJm2weYH7Z+UwLFuuxmM9kRHFlL0Ir0XMDrwiNWfxNXNh1Sp4BOL2EF/9
nduEiS/BVshqYHWFK2ff/QFPTmdaNT05yhtYqh2r4chllSOXrTly9c4JrGbuCCrp8EXgSXuT
WuNJ2eKLaHDi0Rd5fwauWRF/vQVfDybXfLJY3frtlvoYwRvXcG0/f32a/PHq3B2gPj55s4Bx
Oxmt5uiY5Ut4wcuVTUCFIX6DHPgJMOL514mbtEdTW8DODSJ46G7maWZjJxIao+C7w0fBhh7h
EH8MOsO6PtjRV9ObiQtIFo8bajT1UQK6w/hlKcatiaohbT0aHBbN2rF6jgYLyA0r/M320WCf
tFdRNZ7UwdHAMM3RHsVtq5C0XIzKR4WxyQN+gGNxwwdVzVpUTVVml6wa1gPKxhHeUDbluoGm
u9Aa6ibtLIpVkMReZ1KDLGnU63z8dbK08L9+et6Q4A2JJoOC8X5b+4uGnGzIrTEmcPJhAVDa
1ETsUTM/30GkfTTAszKjG8+GrQNLmTBFhTMcPKl2H/lqdXPT+yNzI21VjRpWz488nhDSQJNd
aLEfOatDGtKALD/y8ffZCGO+v30+azze1E3zC3uZ4nmRgaXFiTgdz/MfwwR+SX4FT9j6ioti
V/jRyePkX9P5NPltBlrMS2HKbXWwPkXuoKGGuLNl8LdubGDbiNVwxfFRSTC/cXp3v6q9eE0B
uHV+5At6HMEH9hz+qM7lj5DsH4Fajqxq3K841o4srvs1q7Vps1Ghb4NieQYwNsQRMHzxEjPo
MkwesmJPnAaz6jW+kxScsN8mPy9n+XycfAl0+k+smwqdGtR7abu20RV7iugwr0/qr09qbUos
E9X9+rT5+mT99c9sisUW7171Qxsm6zYrjVk/ect8Ryts1tH6m3XTwFPdeI05z6s5L9bmvGyA
mjXQctYXI+rI6fbV6m5UHR4BYdwFI2vCnTbAStA1iaZ9B8pHM1OkEKCIEOiUrg3Ilq49ODhz
NzjJETR/ZLtw5DtS/L4+S2mtJ/Zi5fAwxU+V2h8bw5Q2hmkWmqUtr7I5anM7amUxi7KqY9Av
9Z9VUWMms1pPOO60dquIN1XE1lW0NpO31Q+peoUewn9WP7SuH17rib2SqVs/oqkffiD9lANb
E0mwSkWdYry8G6NRG91M8jvMXivmME8zJWxpQZf5+fYz1kLFPydvZl+TY1+P6kN+B0QH97qm
t/c3k9sJ3guT/Jws0wKGMFkr01gkwhBYfTszYUDQKInVifzXfD/7AUb4+Wq5XPt0b97+cf6/
5x/P8NvBn9///uH5W/xz7buIOibGsXwN5zrkFxB89WfxIM2kweDVj9spmjoMXTVyKDnmZNra
vdP722lyC7rAg0JFLePidZgpTv2gANG4R3v6/uw0OXfZJadr7kxae9je7oDoFwvow71Pf/w+
zZPzs+en784bj4rao+5/Y6QNT5zlGn0ouzdJbPkwROH+BEoDQ9Yw4Pvicw4Kl8TR9GqKeVGj
hUteAKd+dD0toqkewdQQ/JnLhxEwN3Z6NCtLnNk+A8O+wcTT6i8pcMS1TnMl8Bz17XQ0n2E9
5yEmL2TJYvr1KT4vx8BT76/gzxq5+XdbMQ1+UnUIzXllUd+fJOf3k/wbfMGGcfAZQ2AlFvff
5vWRJUskyTLM8huPxpd46sv+hsm0Nzf+Yy9wyYRBgnMkeZ7DDPY5Wo+K0SJSDIkCeXlcoWoj
A5MHiK49GJzfWr94+WM2/1bzjSfLa4KU1j3BSjRNDIacmgojvRSmqWXZ048n7y5+jJf+gGAC
Pya/58ClX4Bx+GjzAPzbWaetJq4walGJr2wUxHUWj629fXfx4eXzd+8+Jlc3+dcnZW1pHzFM
LrFg+Hz8I59PjhqzQDPr4DTfjfZ7N5Hh8tGEYP0g8Jj6OgTvB6E434AQ/SC0ZBsvIvtBGGUz
mBoQqheEyTRSuRrEWfHH5NP9GE2AGyPD5DvF9e6X5RRvFvtnPv2e/980v0uvFjC209EsXX17
Bk7uBLdw3s1Xl3nRBuNaVNU1y/mBO90PzA9bXB/nSQHFM22LjPScan6KebTy5QVWEM1Kc1j8
buMVlkU0TZlAf5kFHz/BKpmYiL9wSdfQ9tVsmIxGaUNYBoXP8p+Xk2T27UlyuVr6pQo4zjKZ
r+5wkfoJZnb2o0yjRyy8eiaI5WrwI016fnaCp0HvLpBi22ohNKd4PnY2Lv6KYLFz0KD/mWaP
6y3gCcVAC3ZlxPWhUu9G+iVPlWA24uyXKAF2l2ffksWP/B49IbTaR7hPkCZAcKYzjNIOBySZ
/I2HSRZDkuQwCBeLYSFY4Bq8GU5t7Ffdrm6W0/t8eV3f5sLNl6Y7YJS78qtNujgPNMAA8bB2
vpaGoGwV0DUoezgYeJPgGOuvdWtiD+V89clY9V0Gi8XxHFt4E85J5k6RS4xZ23PDtqUKgdg7
1fbTG4Bq3RKM640rkXmFHjAOjuTR8fvTUp0qpdXiaXCxwXygmfVxh1Vy9An4aZje/dz9n8oM
geeeEoC8n09vEgomDlgqqQANzfCGD51R8tcQf0vJv5PPb47fJuf+wBOsdj4+K1LQvMQg8+UU
5+t8ggYPvJrL5Bf4mwF5ho4PKR4uMuhf/vGRDq4W1j/Hw+2w0N3Zzt8WewHg9l9PRt/AGl3h
nsPq7s5GJejVYvQNd/fmEzx3MrkrRxSelKeKB/fhrdEq6kfYLfjE3lEArvm9zc9Iru6/wFjE
xIk0TfEnUAAY2AJaaGmv3WqFfnt64q5Hga59usfSIRlSm8v7hQ2vJuMV8Ia/nySvwBAVBxcw
auxdS4LuA4YUQTWXvqAKrhbrhwrwOWK0sS7ohXtwaKOMtgAQ/CIxh/5qeoOLyAnGAz9O8ttS
lmmKNT8fPPKQlRK4AWpNtuzfHKNAVddjPM4B6h+DAjysh6A3rU9tktK4SeqwdLZpB2MnqUVQ
ynSajD69ASi2dW+MwGEhG5dT4vh0F34SPuFDIrEw/cYlVfgdsxIDfjKbOTem+4iEE7TldUKC
dgOweuPkkZ0Zg2f4mLdiDsGOsy8W4gLe8OL7FS6rRKtHMMX+e/z4z/J4XjEp8MDeauIX5+rK
LoDDPI5sM7XKlAmELJST5QQVXz92b+y9ZdFqZOAT0U07ZLoz3rwg38zrsoJxagQEgt3fRY2s
ehOBxag2zZ6pMptCGWpOUJD1OgjGXu0XrUbAkDI0GukDakTBwEkfKxinRkBQePZ4FzWK6k3A
TmQs9F1pocZQvp4TpM0azVaM9VEjYFgffaNx9oAaUZCEhjGLVSMiYPBoFzWq6k2M0ZptZj7b
Djk1hrIXrSDeMruhRt5HjYBBAhmQFqVTjSioQ73msWrEW4eRbu+iRlO8iUzBN7VFN0IdcmoM
5XI6QS02baOIVyNimCyQDWxROtToBAOp/VYwRo0OAbcld1HjZfUmnGlbMiDUIafGUGarE5TN
6u9WTPZRI2CowJlEi9KpRhSUoZVaxqoREPSuS8y4ehMpNAkkCNsOOTWG8nydIDObk1r1USNg
iOBKrR5QIwry0KRWsWrEfAeyoxqvqjfRYGtly5s4NQaynimDSS9cCOzzq9N3ySD5BAQ+eYO5
qMntZJkPmoWyoGWX+UqFSjWwRNVhlmi0x4ZoBgsVwAuMvs5nq/thcjO9/D6dL8fJIwbU67Fn
lhiZWeBv7jH7SrXaBf9wJ5n/kfy4no6ubaWw6R1eLHczwZqP08k8n4+ufxb5mCmQlxraIrnN
fyaja7vZczm5zr9PZ3iwPwFCDSwO94DTqrvo8lbdLVueT/5aTYHjlMfGgMJfVC2D204wfoOQ
WJ6xAtSZwTXqr8ntauCic4O/tcTjZ469uxxiwahEkNwegZjizth/1SFwnXgAQuMcoBkPw2iM
qxoMfn+/Av6+SSceHt4IYtDWhux8F5VwgsRGH7ajEh6BZDt6HeXABB8NvktvKkGVShUj1nnb
w/wANHgpjgHFbceHh0BPZJfxgSfsjZZoeLcfH5qkGdP2WEKbclg0T0E0GK+C7aAcDyEfnn+d
ytG4HcBFm3KiWBzVMhVSZGhZWzTcPuoMJnJKuzK1dKCVtTHDU+C+jHjZCyyc5/ejhsmncv8q
H1n7ltg0UgvjAjqzq0YvHST4rkJYZ3N3SOIgZZphfRjePnR4NDdDNGIE0x2BBxFNURCNcUF0
x5oooz11RBN4DLbjTVW0w4poQKa17PA4dLTfhmiacutItqGZaPeFZzTlBI3T9tErj0GDDnnX
kuMFbTbmdkuOR7CJQntYchBOMm1YSxyudfI7QUPUZhAwOnrlMWx95F7Rq0JQhXodZfc8gkCn
YQ/RK4TTQqvAoe5uO+gFDVfbR68cBnhAIYbQFb3ygvbO2O2iVwUCnrzaQ/SKYyFOpUXQI+uK
XnnBtdKG/aJXHkPzkDa6oleFoAxN6qjolUcwbMdJrao3oUaH/ciu6JUXFHyH6JXHkIFDsd3R
Ky+ogh8/KnpVIHQtiT2iVwgH62sWOBfcHb3ygiywxERHrzxG6Px0d/SqEFQhUxQVvfIIQnb4
Aj2iVwinGMzqlnBaa/TKCepMbY7G6OiVx6CBA9Pd0atCkIaGcVT0qkAwO9rGcfUmRigZKMbR
Hb3ygnqX6JXD0BkLDaqu6FUhKEKmKCp65RE66VuP6BXPeEqUywbrFb3iJEszAg12bNTEc2xE
I4pI2WGq4kkpojFG7BU0u/MURBMZ8P+OgRvPUxBNSkLMXngKooFhzWRH3+J5CqJh6Ih0oMXz
FE5sWX1FO6JBPXiKJqnmhPuC99vxFIchaW+e4gUD+S2xPMUhqF1dmmK+aJpmktDgctjJU5zg
2m26PXmKw1BBR6CTpzhBHdwQjeMpHkHvGGFk1ZtQexi8L09xgjRA9+J5isMI7/J28hQv2Lap
HadGQBBkR7onqjeBP2ram6dYQWIzorfmKQ6DqFDjnTzFCwajFnE8xSHQrkhMH54CcGAtbVp1
P57iBLXcHI3xPMVitET/O3mKF6QttCBOjYCw87aBqd7E+PKR/XiKExRqM+cjnqc4DBUooPcA
T/GCNOQZxvEUh6CzHRO5CmdAM3ufTqAo0wM8xQnaS8i25ikOw5Yc7cdTvKAOeeZxPMUh2AKW
++ApAMeUMb132a0gZgFv2sZ4nuIwWNBN6OQpXjBoVON4ikOwldL2wVMAToAWRd9ddm4U5g/b
LIc98BRAU1Jyuv1ecQEhdtvu4kanmeA2Nrj1XiAsXpjtTmhHaCOedgmMfoJTJLffCywg1G4b
6SKzJ/fsEfet9wJFJmHmutJVffcCBYH3yHTr1+nyLUEqNeAGYPn/Pe0FaoFVFQ1FCrunvUCE
5NyQrj32eI6NaPDCpitfMZ5jIxqe6806eGw8x0Y0w7XqWlfjObYWsLzAyKAdRDCeYyMa3rWh
O75CPMfWApYk487YbsuxHQY4oy1beq1LjhckWWjljrJmHoFmO7IaUr0J3lvbFi1onfxe0MjN
CGM0x3YYjAUqlHZz7EJQtiSOx6kREPiuEUa/KmiZpYQREYyVdtpBJ6jE5miM5tgew6iQNro4
diEY9COjOLZDQDq3F46NcEwAYGhAdHFsLyjk5u5LNMf2GCqYAtzFsQvBQIXeSI7tEXRXTLIH
x0Y4AewsuB3UxbG9oM1x2JZjewzOQt+wi2MXgsHNjiiO7REE3XFSm+pNlMl0MJm5i2M7QTDy
m6wmmmN7DEpCEYcujl0IBs4SRnJsj8CyHdVYOAOSpPCTDJqnLo7tBbXejIZHc2yHAXY6NKm7
OHYhGORiURzbI9gb5PbAsRGOsiw8Pbo4theUgUkdzbE9huYtVLlTjSgYPGUVxbE9guE7Hpa6
qt4ECCVlLW/SwrENExmzJXi6NjdiObZDY0Ta+N1WNLKEsKH1rWmkg8FAFtueYyOISgVGmTv8
gFiOjWga0cjWycgVhMp2VA5Yeubu296SYwMI8GTQgS0f0I9joywmVQu7Cd+PYxuu7Pk4XlWc
HxbfJl8u7y6md8uL8QRm+gQvqmBDnkmK3yl7/Oeb448nv758gTV5J3e2xBd8ILyoDV/t0W2+
+GYvmC+bqK7geLAJ6Zt4/eHEXnMzmK2Wrs6F0DCAClAN47G8nuMw/YYmdHmeZcd+j0tQwxml
h+03NFEeod6x36oANYIbfth+G4EJBnvst41ZCC7jB1/vfvsmlCD76felA2VpBjO6pF2H6Ldt
wpQx8R37PSpBFa8SmQ/Ub8Wrba39jBNcublm0YNvq35DEybbkz1x/VY81YRWmQQH6LdvQkWb
2gj7bUElrY4kH6jfklKxV3sCoIZRFQ+6Vb+hCU33PU4Mdvyw+oYmGN+nvk1m71oR+nD2xDch
5Z7sty5Awe1W8YvwVv2GJvbmn5T9VoRScVh9QxOM7tN+W1AFdjD6I27Xb7U/O+j0zUXKqZH8
gP12TSiyJ32PSlA823A4e+KbMPFLcsw4AVBwY6k+4Lx0TTCxp3kpClCZYUm3g/Ybm9DRVDDC
j4VlIaWwJMQvClv02zYhSLSrHNtv3E48HL/0TZh4U9vd77wAZeLg+oYmBNmnf4KgnPAqO+gw
/eZEZHxP/Xb6xoQC8B1ktHHt32/XhIpfImLGN4IqYeQBx4ltQmZsr+PEZltIm7Z9wH5DE2K/
fpXADFmVHTB+4psge42fGEwloFQfVN+2CSP3tO7oElS5opGH7Dc0EU9NIvWtOPDLw/YbmtB0
n/FYBNUZY/HO8Vb9hiaqu2r3om+pUprh9YCH67droseSHGO/ERRMVDxp3a7fQiq2V14MoMD8
7O3RB+w3luCl+7EnI1GCanXI+KBvwmR7GidO34qlPHPn4g7Vb9eEvQxmv/0WGTtgvMo3sbd5
qQpQQbMeH3GrfmMTeq/zEkF1LSPnQP3WpCrisBderHUqlBHZ4fYviyb2tc6bAlRSrckB1x3f
RHyIPWZ8I6gxjB9uX8o3weme7ElegCo8N3HA9RKbkLXSyXvQN5BsYjORg1Ue27OIK8FgNcaY
fA2PsHvepstmsXDm/wcs0E1xHMeHa3kDUCOwP2ZuYIF1lRvuFcAIjSZk7rKFm2BpTI1dthDj
zCyMLC1wnGuEfZUGAEyaQ7MMUgEA
--------------000100020706010704050504
Content-Type: text/x-vcard; charset=utf-8;
 name="yoann_juet.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="yoann_juet.vcf"

begin:vcard
fn:Yoann Juet
n:Juet;Yoann
org;quoted-printable;quoted-printable:Direction des Syst=3DC3=3DA8mes d'I=
nformation;P=3DC3=3DB4le R=3DC3=3DA9seau
adr;quoted-printable:BP 92208;;2 rue de la Houssini=3DC3=3DA8re;Nantes Ce=
dex 3;;44322;France
email;internet:yoann.juet@univ-nantes.fr
tel;work:02.53.48.49.26
tel;fax:02.53.48.49.09
tel;cell:06.73.15.42.19
version:2.1
end:vcard


--------------000100020706010704050504--

--------------ms050909050000030901090406
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIJcDCC
BKUwggONoAMCAQICEQCaw9r4AWwhPTK3X2MyL6H8MA0GCSqGSIb3DQEBBQUAMDsxCzAJBgNV
BAYTAk5MMQ8wDQYDVQQKEwZURVJFTkExGzAZBgNVBAMTElRFUkVOQSBQZXJzb25hbCBDQTAe
Fw0xMTA4MTcwMDAwMDBaFw0xNDA4MTYyMzU5NTlaMGcxCzAJBgNVBAYTAkZSMR0wGwYDVQQK
ExRVTklWRVJTSVRFIERFIE5BTlRFUzETMBEGA1UEAxMKWW9hbm4gSlVFVDEkMCIGCSqGSIb3
DQEJAhYVanVldC15QHVuaXYtbmFudGVzLmZyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAzT4cyMjT4IaRAql635iNoxjb9ticpoS8Qauq9qGkV2HzDOqjI5SIc0nlU1EOWnbO
05cewhUbOcM1YunHBSahw5cltsC3Uu4D2XAVQ5vD9VmS9kV2eBn3T9vSB1Yz7r7xSPOhHN50
8qspRwgRExu1tFANqG7TMJbFtN5iG22fiQkNzlVLDV3vgB6B9eJaAayfVlZSq+QUMv2dp6AI
8g7Z1tInb7EWVMbB17d7rSfGXJnQHN9wlRduAg2r+PfHcH2Z6Bxmxl66GABxH9keZxdnfo6G
ph0/l0FFj7VwitXEU7V1kTuq7+vZc5qAT/mcSPO471+KzfU14AgEc8qvALV6iQIDAQABo4IB
djCCAXIwHwYDVR0jBBgwFoAUY01DWhlIP8RGwQK6v+4O5YK3ZqYwHQYDVR0OBBYEFKPfL4a9
soFXobME5dHUc30NI4iCMA4GA1UdDwEB/wQEAwIFoDAMBgNVHRMBAf8EAjAAMB0GA1UdJQQW
MBQGCCsGAQUFBwMEBggrBgEFBQcDAjAYBgNVHSAEETAPMA0GCysGAQQBsjEBAgIdMD8GA1Ud
HwQ4MDYwNKAyoDCGLmh0dHA6Ly9jcmwudGNzLnRlcmVuYS5vcmcvVEVSRU5BUGVyc29uYWxD
QS5jcmwwcgYIKwYBBQUHAQEEZjBkMDoGCCsGAQUFBzAChi5odHRwOi8vY3J0LnRjcy50ZXJl
bmEub3JnL1RFUkVOQVBlcnNvbmFsQ0EuY3J0MCYGCCsGAQUFBzABhhpodHRwOi8vb2NzcC50
Y3MudGVyZW5hLm9yZzAkBgNVHREEHTAbgRlZb2Fubi5KdWV0QHVuaXYtbmFudGVzLmZyMA0G
CSqGSIb3DQEBBQUAA4IBAQCsH20G5ntaV5rBAKu+TjhdseCOkRFhExE6W+ImhXJb1aKFLtnt
epvS6pTenXbBp+8OTjOXDJ9JpmA6sbGpy8FYIThiDiRLVMf1kVgU4ECDo2RE6AHtnRJ645Dw
+fvXbFef9u+0aGehKREb6OVdl/6x9DFQvVm/bj9hQtXPusCXYUe1b/ZCbUKFQSfmXwFMLmFb
U64YhP3YRczYaznadT8Cm0INpaYZJatUan74iufwiC71toLGOEnupbQGOLSHalBdAy+u9WGl
5Nm+oE+R+m8tqbRFUn9GSiswSi7RQXxk4O/qOev3/aF+cG4W4D5DCVBsKqTpFcu1fgzdzWQE
IxRTMIIEwzCCA6ugAwIBAgIQc/5X+t+4xQiBe2a5a/At7zANBgkqhkiG9w0BAQUFADCBrjEL
MAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0IExha2UgQ2l0eTEeMBwG
A1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYDVQQLExhodHRwOi8vd3d3LnVzZXJ0
cnVzdC5jb20xNjA0BgNVBAMTLVVUTi1VU0VSRmlyc3QtQ2xpZW50IEF1dGhlbnRpY2F0aW9u
IGFuZCBFbWFpbDAeFw0wOTA1MTgwMDAwMDBaFw0yODEyMzEyMzU5NTlaMDsxCzAJBgNVBAYT
Ak5MMQ8wDQYDVQQKEwZURVJFTkExGzAZBgNVBAMTElRFUkVOQSBQZXJzb25hbCBDQTCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMgV2fUzaiOhkA3PuwVEw6sfSjWFGiGFoE/4
8EDiSkOb/luxsL+0V9x1gEFLZBr2209vj9AlRTX56stK+vva0+1FiBGUNuTMqA3vxT037RZ7
48KVnlgzfyL7+P/s5r7brgplJSKH2m+Ei0boQIYoP79WCOJK6YOi6SL7Lfq2KB+RwcNx+1PA
K06kDKFunVXt7OEkhzoI4g0c5MRN0Msn+oRk5tGXnVYkW5O7KS5D4kFqPeJKZfyaX1qGh7yH
x3mAlplRxpAPZJGZfRDdrCwDKuF4ZP7OPU70K1ARS9FY1JsD8H/1O1OwU0P7xS/EBCkaOqzX
VenRDpXROzF/eE+uKS0CAwEAAaOCAU0wggFJMB8GA1UdIwQYMBaAFImCZ33EnSZwAEu0UEh8
3j2uBG59MB0GA1UdDgQWBBRjTUNaGUg/xEbBArq/7g7lgrdmpjAOBgNVHQ8BAf8EBAMCAQYw
EgYDVR0TAQH/BAgwBgEB/wIBADAYBgNVHSAEETAPMA0GCysGAQQBsjEBAgIdMFgGA1UdHwRR
ME8wTaBLoEmGR2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VVE4tVVNFUkZpcnN0LUNsaWVu
dEF1dGhlbnRpY2F0aW9uYW5kRW1haWwuY3JsMG8GCCsGAQUFBwEBBGMwYTA4BggrBgEFBQcw
AoYsaHR0cDovL2NydC51c2VydHJ1c3QuY29tL1VUTkFBQUNsaWVudF9DQS5jcnQwJQYIKwYB
BQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEFBQADggEBAAYr
qVMvE9xcORbMhp9eTHty++yNVYpemgr/U0x29AY9UM9X8KLPr5mMqv6gGXY+mQMy+nWDOIq7
a5qlDBOy1Bt25pQuZ5hZ45FsApCanMhgS1WryohajSvlaZUDB9HUDvwkIi5ZsWOkX+3ZI3Lk
nM46XGwfT6kAyR3++n9FLbYuhN0PJ6BZGE7VdiVF9JkmedtvnyP3Q7srDwSjgSYst3s1+T13
X0Ah5n8dpZZavdDLFjpsu2GLiv0EOUQKyyzhy84uEJga2+CT7UlkZAggn7ejUPCi3cq0xnwM
PedeFdwnhuQ6O1JaF6upBlMrnQlzZBwBw/0w0ocDb+QVA3o5X2gxggMKMIIDBgIBATBQMDsx
CzAJBgNVBAYTAk5MMQ8wDQYDVQQKEwZURVJFTkExGzAZBgNVBAMTElRFUkVOQSBQZXJzb25h
bCBDQQIRAJrD2vgBbCE9MrdfYzIvofwwCQYFKw4DAhoFAKCCAY8wGAYJKoZIhvcNAQkDMQsG
CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTQwMjEyMTU1NDU2WjAjBgkqhkiG9w0BCQQx
FgQUvnVqxjpfKXs7QgZafYa+Hre/OT0wXwYJKwYBBAGCNxAEMVIwUDA7MQswCQYDVQQGEwJO
TDEPMA0GA1UEChMGVEVSRU5BMRswGQYDVQQDExJURVJFTkEgUGVyc29uYWwgQ0ECEQCaw9r4
AWwhPTK3X2MyL6H8MGEGCyqGSIb3DQEJEAILMVKgUDA7MQswCQYDVQQGEwJOTDEPMA0GA1UE
ChMGVEVSRU5BMRswGQYDVQQDExJURVJFTkEgUGVyc29uYWwgQ0ECEQCaw9r4AWwhPTK3X2My
L6H8MGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEqMAsGCWCGSAFlAwQBAjAKBggqhkiG
9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcN
AwICASgwDQYJKoZIhvcNAQEBBQAEggEAZyFE5h1ODNp2wWhm4OksgX5OaZ7bU1PRVDCRFPJC
aZ+FRw1IoFGFyxz6PNfJUpcgS1Pw+goUi7kxE4Osp+3OghHHba1F5qJrsaf9YyY8Oht4BQ/3
rOCEREKL31kU2EPMrJ3IEBinbbw+i94+wZpjEBS0hsHEKPDwVQT+nJ4iM+uKtR3b1+gnusnF
Y1Olc5yu5+p3LZ7GXR1DuJzdTKfxB2gV7s8T7pR/c1yANGzxJ5zO4cK5muYrBSCSiN1Og2+E
rwHfYDR4yyYv2mbANRTmBf4hL4E81kkF/xiyosy93Bq1aTZT9gWmV78mcCx9pfBceDO6yYQo
ZuG+upnqcojaDwAAAAAAAA==
--------------ms050909050000030901090406--
