From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: network traffic stop with 2.6.29 after ftp put
Date: Tue, 24 Mar 2009 12:01:39 +0100
Message-ID: <BAY103-DAV100CC8DA92566937097718B2930@phx.gbl>
References: <BAY103-DAV683AFCEC466B8F2E6D8EBB2930@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s27.bay0.hotmail.com ([65.54.246.227]:12723 "EHLO
	bay0-omc3-s27.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753986AbZCXLCS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 07:02:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:

> Hi Folks,
> 
> Just finished compiling linux 2.6.29 on
> Slackware 12.2
> Linux 2.6.29 stop sending/receiving any
> kind of packets (ipv4 on 3c59x) after less
> then 20MB of ftp/mput.
> Running tcpdump on the eth0 doesn't catch
> any traffic. I only see the arp requests.
> Hopefully I can reproduce the problem :-)

me again.
Linux doesn't respond even to 127.0.0.1 :-((

root@Calimero:~# ping 172.16.1.247
PING 172.16.1.247 (172.16.1.247) 56(84) bytes of data.
^C
--- 172.16.1.247 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3010ms

root@Calimero:~# ping 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
^C
--- 127.0.0.1 ping statistics ---
8 packets transmitted, 0 received, 100% packet loss, time 7023ms

root@Calimero:~# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:01:02:ad:db:82
          inet addr:172.16.1.247  Bcast:172.16.1.255  Mask:255.255.254.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:14638 errors:0 dropped:0 overruns:1 frame:0
          TX packets:1160 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3087263 (2.9 MiB)  TX bytes:117736 (114.9 KiB)
          Interrupt:5

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:18 errors:0 dropped:0 overruns:0 frame:0
          TX packets:18 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:6219 (6.0 KiB)  TX bytes:6219 (6.0 KiB)

BTW this is the output from lsmod:

root@Calimero:~# lsmod
Module                  Size  Used by
sd_mod                 20272  0
scsi_mod               76900  1 sd_mod
ide_cd_mod             24944  0
cdrom                  28856  1 ide_cd_mod
floppy                 44836  0
i810                   14568  1
drm                   117996  2 i810
i2c_core               17644  1 drm
snd_seq_oss            24232  0
snd_seq_midi_event      5184  1 snd_seq_oss
snd_seq                38396  4 snd_seq_oss,snd_seq_midi_event
snd_seq_device          5404  2 snd_seq_oss,snd_seq
snd_pcm_oss            30556  0
snd_mixer_oss          11876  1 snd_pcm_oss
snd_intel8x0           25580  3
snd_ac97_codec         86612  1 snd_intel8x0
ac97_bus                1264  1 snd_ac97_codec
snd_pcm                50756  4 snd_pcm_oss,snd_intel8x0,snd_ac97_codec
snd_timer              16372  3 snd_seq,snd_pcm
snd                    40672  13 snd_seq_oss,snd_seq,snd_seq_device,snd_pcm_oss,snd_mixer_oss,snd_intel8x0,snd_ac97_codec,snd_pcm,snd_timer
soundcore               5172  1 snd
snd_page_alloc          7048  2 snd_intel8x0,snd_pcm
usbhid                 13604  0
hid                    28164  1 usbhid
uhci_hcd               18416  0
usbcore               108128  3 usbhid,uhci_hcd
intel_agp              22500  1
3c59x                  34612  0
mii                     3860  1 3c59x
agpgart                25344  3 drm,intel_agp
