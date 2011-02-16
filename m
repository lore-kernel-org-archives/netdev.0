From: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Subject: Re: NFS on little-endian platform - Microblaze
Date: Wed, 16 Feb 2011 14:16:51 +0100
Message-ID: <4D5BCE43.1090401@monstr.eu>
References: <4D5BCC74.9010301@monstr.eu>
Reply-To: monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D5BCC74.9010301-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi again,

I forget to cc linux-nfs mailing list.

Michal

P.S.: Tested on kernels 2.6.38-rc4, 2.6.37 and 2.6.36

Michal Simek wrote:
> Hi All,
> 
> I am trying to understand one problem which we have found.
> The problem is that I can't on Microblaze little-endian platform
> mount nfs without -o nolock options. (Log below)
> Selecting tcp or udp has no effect.
> I am using emaclite driver and there is no problem on big endian 
> microblaze.
> 
> ping, telnet, http, ftp, iperf, netperf work well.
> 
> That's why I have a question if there is any endian specific option for 
> NFS?
> 
> Thanks,
> Michal
> 
> ~ # mount -t nfs 192.168.0.101:/tftpboot/nfs /mnt
> svc: failed to register lockdv1 RPC service (errno 13).
> lockd_up: makesock failed, error=-13
> svc: failed to register lockdv1 RPC service (errno 13).
> ~ # mount -t nfs -o nolock 192.168.0.101:/tftpboot/nfs /mnt
> ~ # mount
> rootfs on / type rootfs (rw)
> proc on /proc type proc (rw,relatime)
> none on /var type ramfs (rw,relatime)
> none on /sys type sysfs (rw,relatime)
> none on /etc/config type ramfs (rw,relatime)
> none on /dev/pts type devpts (rw,relatime,mode=600)
> 192.168.0.101:/tftpboot/nfs on /mnt type nfs 
> (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,nolock,proto=udp,port=65535,timeo=7,retrans=3,sec=sys,local_lock=all,addr=192.168.0.101) 
> 
> ~ #
> ~ # ps
> PID   USER     TIME   COMMAND
>     1 root       0:02 init
>     2 root       0:00 [kthreadd]
>     3 root       0:00 [ksoftirqd/0]
>     4 root       0:00 [kworker/0:0]
>     5 root       0:00 [kworker/u:0]
>     6 root       0:00 [khelper]
>     7 root       0:00 [sync_supers]
>     8 root       0:00 [bdi-default]
>     9 root       0:00 [kblockd]
>    10 root       0:00 [rpciod]
>    11 root       0:00 [kworker/0:1]
>    12 root       0:00 [kswapd0]
>    13 root       0:00 [fsnotify_mark]
>    14 root       0:00 [aio]
>    15 root       0:00 [nfsiod]
>    16 root       0:00 [kworker/u:1]
>    58 root       0:00 udhcpc -R -n -p /var/run/udhcpc.eth0.pid -i eth0
>    62 1          0:00 /bin/portmap
>    64 root       0:00 /bin/inetd /etc/inetd.conf
>    65 root       0:01 -sh
>    66 root       0:00 /bin/syslogd -n
>    67 root       0:00 /bin/flatfsd
>    68 root       0:00 [kworker/0:2]
>    91 root       0:00 ps
> ~ # cat /proc/cpuinfo
> CPU-Family:     MicroBlaze
> FPGA-Arch:      spartan6
> CPU-Ver:        8.00.a, little endian
> CPU-MHz:        50.00
> BogoMips:       24.06
> HW:
>  Shift:         yes
>  MSR:           yes
>  PCMP:          yes
>  DIV:           yes
>  MMU:           3
>  MUL:           v2
>  FPU:           no
>  Exc:           op0x0 unal ill iopb dopb zero
> Icache:         16kB    line length:    32B
> Dcache:         16kB    line length:    16B
>                 write-through
> HW-Debug:       yes
> PVR-USR1:       00
> PVR-USR2:       00000000
> Page size:      4096
> ~ #
> 
> 
> 


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
