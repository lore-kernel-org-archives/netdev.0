From: Tom London <selinux@gmail.com>
Subject: Re: return of ip_rt_bug()
Date: Thu, 4 Aug 2011 19:45:24 -0700
Message-ID: <CAFiZG+UY+Rn=wqi6b9CM0CcARHJUGiqh_jpfEveGLhm+D2hNhA@mail.gmail.com>
References: <20110802170942.GA17164@redhat.com>
	<alpine.LFD.2.00.1108041422510.1495@ja.ssi.bg>
	<CAFiZG+X0oyTOXqm4b0g_UEGYK_0JCW3=WOR5d_7GfbJrTMhMzg@mail.gmail.com>
	<alpine.LFD.2.00.1108042034540.1495@ja.ssi.bg>
	<CAFiZG+W9-vV6o9EbuVEwztW4sQ1QV-MxD+xCHFw7TbNAryzN6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:44647 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755720Ab1HECp0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 22:45:26 -0400
Received: by qyk34 with SMTP id 34so147298qyk.19
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 19:45:25 -0700 (PDT)
In-Reply-To: <CAFiZG+W9-vV6o9EbuVEwztW4sQ1QV-MxD+xCHFw7TbNAryzN6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 4, 2011 at 10:48 AM, Tom London <selinux@gmail.com> wrote:
> On Thu, Aug 4, 2011 at 10:37 AM, Julian Anastasov <ja@ssi.bg> wrote:
>>
>> =A0 =A0 =A0 =A0Hello,
>>
>> On Thu, 4 Aug 2011, Tom London wrote:
>>
>>> How else can I help?
>>
>> =A0 =A0 =A0 =A0From your bug report at
>> https://bugzilla.redhat.com/show_bug.cgi?id=3D712632 I see that
>> the application is xsane, "Manufacturer: EPSON". I downloaded
>> some sources and in sane-backends-git20110804/sanei/sanei_udp.c
>> I see some UDP usage.
>>
>> =A0 =A0 =A0 =A0For example, sane-backends-git20110804/backend/epson2=
=2Ec
>> calls sanei_udp_open_broadcast (UDP socket with SO_BROADCAST).
>> The socket is not bound, not connected, application sends packet to
>> 255.255.255.255:3289 in blocking mode and waits for reply for
>> 1 second. It is done for "net autodiscovery" config. As the socket
>> is not bound, kernel should search source address for every packet.
>> Nothing special so far. Not sure why your report has 2 oopses in
>> period of 1 second, may be config has 2 lines "net autodiscovery"
>> and 2 packets are sent?
>>
>> =A0 =A0 =A0 =A0Your first report was for 192.168.2.5 but
>> I don't see the IP from your last report that is with
>> kernel-3.1.0-0.rc0.git12.1.fc17.x86_64. Now you show local IP is
>> 192.168.2.6. Do you have 192.168.2.5 as local IP, what shows
>> 'ip addr' ?
>>
>> =A0 =A0 =A0 =A0Can you confirm that the IP you see in oops is always
>> configured (ip addr). Or may be it comes from DHCP and now is
>> 192.168.2.6?
>>
>> =A0 =A0 =A0 =A0Can you start 'ip monitor' in one console while
>> attaching the USB device, so that we can know if any IP
>> addresses are reconfigured due to some events. For example,
>> script that restarts DHCP.
>>
>> Regards
>>
>> --
>> Julian Anastasov <ja@ssi.bg>
>>
>
> Sure. =A0I'll set this up when I get back home this evening.
>
> Not sure about the 192.168.2.5 =A0vs 192.168.2.6 confusion. =A0My lap=
top
> is connected to a Belkin router, and uses DHCP. =A0I sometimes have t=
he
> wireless interface connected as well, so perhaps this sometimes occur=
s
> when only the wired NIC is connected and sometimes when both the wire=
d
> and wireless NICs are connected? =A0I'll also see if I can uncover an=
y
> DHCP history
>
> I'll try to follow the above instructions, and will report out about =
8PM PDT.
>
> tom

OK.  Booted up.  Here is what 'ifconfig' says:

[root@tlondon ~]# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:1F:16:0B:56:A8
          inet addr:192.168.2.6  Bcast:192.168.2.255  Mask:255.255.255.=
0
          inet6 addr: fe80::21f:16ff:fe0b:56a8/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2101 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1814 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1719912 (1.6 MiB)  TX bytes:268153 (261.8 KiB)
          Interrupt:20 Memory:f2600000-f2620000

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:79 errors:0 dropped:0 overruns:0 frame:0
          TX packets:79 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:19162 (18.7 KiB)  TX bytes:19162 (18.7 KiB)

virbr0    Link encap:Ethernet  HWaddr 52:54:00:B9:89:30
          inet addr:192.168.122.1  Bcast:192.168.122.255  Mask:255.255.=
255.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

wlan0     Link encap:Ethernet  HWaddr 00:21:5D:AC:C6:92
          inet addr:192.168.2.9  Bcast:192.168.2.255  Mask:255.255.255.=
0
          inet6 addr: fe80::221:5dff:feac:c692/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:22 errors:0 dropped:0 overruns:0 frame:0
          TX packets:26 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2767 (2.7 KiB)  TX bytes:5705 (5.5 KiB)

[root@tlondon ~]#

'ip addr' says:
[root@tlondon ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 00:1f:16:0b:56:a8 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.6/24 brd 192.168.2.255 scope global eth0
    inet6 fe80::21f:16ff:fe0b:56a8/64 scope link
       valid_lft forever preferred_lft forever
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP =
qlen 1000
    link/ether 00:21:5d:ac:c6:92 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.9/24 brd 192.168.2.255 scope global wlan0
    inet6 fe80::221:5dff:feac:c692/64 scope link
       valid_lft forever preferred_lft forever
4: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
state DOWN
    link/ether 52:54:00:b9:89:30 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
5: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc noop master virbr0
state DOWN qlen 500
    link/ether 52:54:00:b9:89:30 brd ff:ff:ff:ff:ff:ff
[root@tlondon ~]#


 I ran 'ip monitor' in one terminal window, ran 'inotail -f
/var/log/messages' in another, started 'gimp', and
did a 'create from usb:epson'.

I got this in the 'ip monitor' window:

[root@tlondon ~]# ip monitor
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether
192.168.2.1 dev eth0 lladdr 00:1c:df:e2:3e:e9 STALE


I got this in the 'inotify -f /var/log/messages' window:

Aug  4 19:29:27 tlondon kernel: [  305.997223] usb 3-1: new full speed
USB device number 2 using uhci_hcd
Aug  4 19:29:28 tlondon kernel: [  306.581320] usb 3-1: New USB device
found, idVendor=3D04b8, idProduct=3D010a
Aug  4 19:29:28 tlondon kernel: [  306.581332] usb 3-1: New USB device
strings: Mfr=3D1, Product=3D2, SerialNumber=3D0
Aug  4 19:29:28 tlondon kernel: [  306.581340] usb 3-1: Product: Perfec=
tion1640
Aug  4 19:29:28 tlondon kernel: [  306.581346] usb 3-1: Manufacturer: E=
PSON
Aug  4 19:29:28 tlondon mtp-probe: checking bus 3, device 2:
"/sys/devices/pci0000:00/0000:00:1a.0/usb3/3-1"
Aug  4 19:29:28 tlondon mtp-probe: bus: 3, device: 2 was not an MTP dev=
ice
Aug  4 19:30:07 tlondon kernel: [  345.300960] ------------[ cut here
]------------
Aug  4 19:30:07 tlondon kernel: [  345.300977] WARNING: at
net/ipv4/route.c:1714 ip_rt_bug+0x5c/0x62()
Aug  4 19:30:07 tlondon kernel: [  345.300984] Hardware name: 74585FU
Aug  4 19:30:07 tlondon kernel: [  345.300989] Modules linked in: fuse
ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state
nf_conntrack xt_CHECKSUM ppdev iptable_mangle parport_pc lp parport
tun bridge stp llc rfcomm bnep usblp arc4 snd_usb_audio
snd_usbmidi_lib snd_hda_codec_conexant snd_rawmidi uvcvideo videodev
snd_hda_intel snd_hda_codec media v4l2_compat_ioctl32 snd_hwdep
snd_seq snd_seq_device iwlagn snd_pcm btusb microcode iTCO_wdt
i2c_i801 iTCO_vendor_support thinkpad_acpi mac80211 snd_timer
bluetooth cfg80211 snd_page_alloc rfkill snd soundcore e1000e
virtio_net kvm_intel kvm uinput wmi i915 drm_kms_helper drm
i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
Aug  4 19:30:07 tlondon kernel: [  345.301272] Pid: 2348, comm: xsane
Not tainted 3.1.0-0.rc0.git17.1.fc17.x86_64 #1
Aug  4 19:30:07 tlondon kernel: [  345.301280] Call Trace:
Aug  4 19:30:07 tlondon kernel: [  345.301300]  [<ffffffff8105c470>]
warn_slowpath_common+0x83/0x9b
Aug  4 19:30:07 tlondon kernel: [  345.301315]  [<ffffffff8105c4a2>]
warn_slowpath_null+0x1a/0x1c
Aug  4 19:30:07 tlondon kernel: [  345.301329]  [<ffffffff8142f625>]
ip_rt_bug+0x5c/0x62
Aug  4 19:30:07 tlondon kernel: [  345.301342]  [<ffffffff81437231>]
dst_output+0x19/0x1d
Aug  4 19:30:07 tlondon kernel: [  345.301355]  [<ffffffff81438952>]
ip_local_out+0x20/0x25
Aug  4 19:30:07 tlondon kernel: [  345.301369]  [<ffffffff81439819>]
ip_send_skb+0x19/0x3e
Aug  4 19:30:07 tlondon kernel: [  345.301385]  [<ffffffff81456016>]
udp_send_skb+0x239/0x29b
Aug  4 19:30:07 tlondon kernel: [  345.301399]  [<ffffffff814577b3>]
udp_sendmsg+0x5a1/0x7d4
Aug  4 19:30:07 tlondon kernel: [  345.301415]  [<ffffffff813f69f7>] ?
release_sock+0x35/0x155
Aug  4 19:30:07 tlondon kernel: [  345.301428]  [<ffffffff8143732c>] ?
ip_select_ident+0x3d/0x3d
Aug  4 19:30:07 tlondon kernel: [  345.301443]  [<ffffffff81062587>] ?
local_bh_enable_ip+0xe/0x10
Aug  4 19:30:07 tlondon kernel: [  345.301457]  [<ffffffff814f1519>] ?
_raw_spin_unlock_bh+0x40/0x44
Aug  4 19:30:07 tlondon kernel: [  345.301470]  [<ffffffff813f6b0e>] ?
release_sock+0x14c/0x155
Aug  4 19:30:07 tlondon kernel: [  345.301485]  [<ffffffff8145eccc>]
inet_sendmsg+0x66/0x6f
Aug  4 19:30:07 tlondon kernel: [  345.301498]  [<ffffffff813f1fc2>]
sock_sendmsg+0xe6/0x109
Aug  4 19:30:07 tlondon kernel: [  345.301513]  [<ffffffff8108f078>] ?
lock_acquire+0x10f/0x13e
Aug  4 19:30:07 tlondon kernel: [  345.301528]  [<ffffffff8110d89e>] ?
might_fault+0x5c/0xac
Aug  4 19:30:07 tlondon kernel: [  345.301542]  [<ffffffff8108ef3c>] ?
lock_release+0x1a4/0x1d1
Aug  4 19:30:07 tlondon kernel: [  345.301556]  [<ffffffff8110d8e7>] ?
might_fault+0xa5/0xac
Aug  4 19:30:07 tlondon kernel: [  345.301569]  [<ffffffff813f2d07>] ?
copy_from_user+0x2f/0x31
Aug  4 19:30:07 tlondon kernel: [  345.301582]  [<ffffffff813f4b9d>]
sys_sendto+0x132/0x174
AugAug  4 19:30:08 tlondon kernel: [  346.314606] ------------[ cut
here ]------------
Aug  4 19:30:08 tlondon kernel: [  346.314612] WARNING: at
net/ipv4/route.c:1714 ip_rt_bug+0x5c/0x62()
Aug  4 19:30:08 tlondon kernel: [  346.314615] Hardware name: 74585FU
Aug  4 19:30:08 tlondon kernel: [  346.314616] Modules linked in: fuse
ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state
nf_conntrack xt_CHECKSUM ppdev iptable_mangle parport_pc lp parport
tun bridge stp llc rfcomm bnep usblp arc4 snd_usb_audio
snd_usbmidi_lib snd_hda_codec_conexant snd_rawmidi uvcvideo videodev
snd_hda_intel snd_hda_codec media v4l2_compat_ioctl32 snd_hwdep
snd_seq snd_seq_device iwlagn snd_pcm btusb microcode iTCO_wdt
i2c_i801 iTCO_vendor_support thinkpad_acpi mac80211 snd_timer
bluetooth cfg80211 snd_page_alloc rfkill snd soundcore e1000e
virtio_net kvm_intel kvm uinput wmi i915 drm_kms_helper drm
i2c_algo_bit i2c_core video [last unloaded: scsi_wait_scan]
Aug  4 19:30:08 tlondon kernel: [  346.314693] Pid: 2348, comm: xsane
Tainted: G        W   3.1.0-0.rc0.git17.1.fc17.x86_64 #1
Aug  4 19:30:08 tlondon kernel: [  346.314695] Call Trace:
Aug  4 19:30:08 tlondon kernel: [  346.314701]  [<ffffffff8105c470>]
warn_slowpath_common+0x83/0x9b
Aug  4 19:30:08 tlondon kernel: [  346.314704]  [<ffffffff8105c4a2>]
warn_slowpath_null+0x1a/0x1c
Aug  4 19:30:08 tlondon kernel: [  346.314708]  [<ffffffff8142f625>]
ip_rt_bug+0x5c/0x62
Aug  4 19:30:08 tlondon kernel: [  346.314711]  [<ffffffff81437231>]
dst_output+0x19/0x1d
Aug  4 19:30:08 tlondon kernel: [  346.314714]  [<ffffffff81438952>]
ip_local_out+0x20/0x25
Aug  4 19:30:08 tlondon kernel: [  346.314717]  [<ffffffff81439819>]
ip_send_skb+0x19/0x3e
Aug  4 19:30:08 tlondon kernel: [  346.314721]  [<ffffffff81456016>]
udp_send_skb+0x239/0x29b
Aug  4 19:30:08 tlondon kernel: [  346.314725]  [<ffffffff814577b3>]
udp_sendmsg+0x5a1/0x7d4
Aug  4 19:30:08 tlondon kernel: [  346.314729]  [<ffffffff813f69f7>] ?
release_sock+0x35/0x155
Aug  4 19:30:08 tlondon kernel: [  346.314732]  [<ffffffff8143732c>] ?
ip_select_ident+0x3d/0x3d
Aug  4 19:30:08 tlondon kernel: [  346.314736]  [<ffffffff81062587>] ?
local_bh_enable_ip+0xe/0x10
Aug  4 19:30:08 tlondon kernel: [  346.314740]  [<ffffffff814f1519>] ?
_raw_spin_unlock_bh+0x40/0x44
Aug  4 19:30:08 tlondon kernel: [  346.314743]  [<ffffffff813f6b0e>] ?
release_sock+0x14c/0x155
Aug  4 19:30:08 tlondon kernel: [  346.314747]  [<ffffffff8145eccc>]
inet_sendmsg+0x66/0x6f
Aug  4 19:30:08 tlondon kernel: [  346.314750]  [<ffffffff813f1fc2>]
sock_sendmsg+0xe6/0x109
Aug  4 19:30:08 tlondon kernel: [  346.314754]  [<ffffffff8108f078>] ?
lock_acquire+0x10f/0x13e
Aug  4 19:30:08 tlondon kernel: [  346.314758]  [<ffffffff8110d89e>] ?
might_fault+0x5c/0xac
Aug  4 19:30:08 tlondon kernel: [  346.314761]  [<ffffffff8108ef3c>] ?
lock_release+0x1a4/0x1d1
Aug  4 19:30:08 tlondon kernel: [  346.314765]  [<ffffffff8110d8e7>] ?
might_fault+0xa5/0xac
Aug  4 19:30:08 tlondon kernel: [  346.314768]  [<ffffffff813f2d07>] ?
copy_from_user+0x2f/0x31
Aug  4 19:30:08 tlondon kernel: [  346.314771]  [<ffffffff813f4b9d>]
sys_sendto+0x132/0x174
Aug  4 19:30:08 tlondon kernel: [  346.314775]  [<ffffffff810b29eb>] ?
audit_syscall_entry+0x11c/0x148
Aug  4 19:30:08 tlondon kernel: [  346.314780]  [<ffffffff8124f03e>] ?
trace_hardirqs_on_thunk+0x3a/0x3f
Aug  4 19:30:08 tlondon kernel: [  346.314784]  [<ffffffff814f8382>]
system_call_fastpath+0x16/0x1b
Aug  4 19:30:08 tlondon kernel: [  346.314786] ---[ end trace
97e7c0a8de097c51 ]---

Regarding the 'movable IP Address' issue (.5 vs. .6), I found the
following in /var/lib/dhclient/dhclient-5fb06bd0-0bb0-7ffb-45f1-d6edd65=
f3e03-eth0.lease

lease {
  interface "eth0";
  fixed-address 192.168.2.5;
  option subnet-mask 255.255.255.0;
  option dhcp-lease-time 4294967295;
  option routers 192.168.2.1;
  option dhcp-message-type 5;
  option dhcp-server-identifier 192.168.2.1;
  option domain-name-servers 192.168.2.1;
  option domain-name "TintonFalls";
  renew 4 2079/07/06 21:52:00;
  rebind 1 2130/10/30 06:17:29;
  expire 6 2147/11/04 01:06:07;
}
lease {
  interface "eth0";
  fixed-address 192.168.2.6;
  option subnet-mask 255.255.255.0;
  option dhcp-lease-time 4294967295;
  option routers 192.168.2.1;
  option dhcp-message-type 5;
  option dhcp-server-identifier 192.168.2.1;
  option domain-name-servers 192.168.2.1;
  option domain-name "TintonFalls";
  renew 2 2079/08/22 16:15:42;
  rebind 4 2130/09/07 00:41:11;
  expire 1 2147/09/11 19:29:49;
}

So, my router is just giving my wired NIC different addresses....

More I can provide?

tom
--=20
Tom London
