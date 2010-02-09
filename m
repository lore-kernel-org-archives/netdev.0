From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: netconsole dumbs the system
Date: Tue, 09 Feb 2010 12:34:27 +0100
Message-ID: <87mxziej7f.fsf@tac.ki.iif.hu>
References: <87iqa74f2s.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87iqa74f2s.fsf@tac.ki.iif.hu> (Ferenc Wagner's message of "Mon,
	08 Feb 2010 22:01:31 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ferenc Wagner <wferi@niif.hu> writes:

> # modprobe netconsole netconsole=@10.0.0.6/eth0,@10.0.0.7/
>
> that kills off the consoles: past kernel messages start pouring over all
> consoles, the new network console included, then it suddenly dies off in
> the middle, with one more line on the VC than sent to the network.  At
> this point, the machine still responds to ping, the keyboard leds work,
> but otherwise it's impossible to interact with it.  No SysRq, even.
> Being in the initramfs, there are no network services to test.  If I
> load netconsole in the running system, there isn't much backlog to pour
> out, and the problem doesn't appear.  What could be wrong here?

I really shouldn't harass public mailing lists while running to the
train.  So.  This happens on 2.6.32.7, and has nothing to do with
bonding or vlans.  Stopping early in the initramfs (before any network
setup) and starting netconsole brings down the console for good.  This
time I ran with an IPMI SoL console:

[...]
[   34.315957] sd 1:0:0:0: [sdc] Assuming drive cache: write through
[   34.354246] sd 1:0:0:0: [sdc] Attached SCSI disk

(initramfs) modprobe netconsole netconsole=@10.0.0.6/eth0,@10.0.0.4/
[  786.966032] netconsole: local port 6665
[  786.988917] netconsole: local IP 10.0.0.6
[  787.012829] netconsole: interface eth0
[  787.035185] netconsole: remote port 6666
[  787.058583] netconsole: remote IP 10.0.0.4
[  787.083022] netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
[  787.119428] netconsole: device eth0 not up yet, forcing it
[  787.202838] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  788.200104] tg3: eth0: Link is up at 1000 Mbps, full duplex.
[  788.233896] tg3: eth0: Flow control is off for TX and off for RX.
[  788.270419] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.32.7 (wferi@rs22) (gcc version 4.3.2 (Debian 4.3.2-1.1) ) #1 SMP Sun Feb 7 14:35:57 CET 2010
[...]
[   16.320885] sd 1:0:0:0: [sdc] Result: hostbyte=DID_OK driverbyte=DRIVER_SENSE
[   16.363561] sd 1:0:0:0: [sdc] Sense Key : Not Ready [current] 
[   16.398490] sd 1:0:0:0: [sdc] Add. Sense: Logical unit not ready, manual intervention required
Killed
(initramfs) cat /proc/modules
netconsole 8307 1 - Loading 0xf83d6000
configfs 15052 2 netconsole, Live 0xf83c5000
sd_mod 25601 0 - Live 0xf83ad000
crc_t10dif 1012 1 sd_mod, Live 0xf839a000
usbhid 26560 0 - Live 0xf8320000
hid 50453 1 usbhid, Live 0xf82e8000
ata_generic 2015 0 - Live 0xf7fe9000
ata_piix 17009 0 - Live 0xf7fdd000
libata 113304 2 ata_generic,ata_piix, Live 0xf7fa4000
uhci_hcd 15893 0 - Live 0xf7f51000
mptspi 9545 0 - Live 0xf7f3f000
mptscsih 13672 1 mptspi, Live 0xf7f2c000
ide_pci_generic 1924 0 - Live 0xf7f1d000
mptbase 42788 2 mptspi,mptscsih, Live 0xf7f06000
ehci_hcd 26986 0 - Live 0xf7ee5000
qla2xxx 180864 0 - Live 0xf7e9b000
piix 3556 0 - Live 0xf7e57000
scsi_transport_spi 14722 1 mptspi, Live 0xf7e37000
tg3 87833 0 - Live 0xf7e10000
scsi_transport_fc 28295 1 qla2xxx, Live 0xf7dd8000
scsi_tgt 6834 1 scsi_transport_fc, Live 0xf7dba000
scsi_mod 100649 8 sd_mod,libata,mptspi,mptscsih,qla2xxx,scsi_transport_spi,scsi_transport_fc,scsi_tgt, Live 0xf7d2a000
ide_core 63358 2 ide_pci_generic,piix, Live 0xf7cdd000
libphy 11178 1 tg3, Live 0xf7cb3000
usbcore 97786 4 usbhid,uhci_hcd,ehci_hcd, Live 0xf7c81000
nls_base 4541 1 usbcore, Live 0xf7c4d000
button 3598 0 - Live 0xf7c42000
thermal 9198 0 - Live 0xf7c34000
fan 2590 0 - Live 0xf7c26000
thermal_sys 9378 2 thermal,fan, Live 0xf7c19000
(initramfs) modpro

That is, after the "Killed" message (which I don't quite get, is that
related to the modprobe command?) I was still able to issue a command,
and to start typing another one.  Then came silence...  And not all
kernel messages were sent through the network, only the first part of
it, as the timestamps show.
-- 
Thanks,
Feri.
