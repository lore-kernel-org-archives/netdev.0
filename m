From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7483] New: Unable to handle kernel paging
 request for data at address 0x5a5a5a5a5a5a5a5a
Date: Fri, 10 Nov 2006 01:08:32 -0800
Message-ID: <20061110010832.7cbc481e.akpm@osdl.org>
References: <200611100848.kAA8mVHR025316@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org,
	Steven French <sfrench@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7648 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946098AbWKJJIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 04:08:46 -0500
To: sqy@vnet.ibm.com
In-Reply-To: <200611100848.kAA8mVHR025316@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(switching to email - please follow up via reply-to-all and not via bugzilla)

On Fri, 10 Nov 2006 00:48:31 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7483
> 
>            Summary: Unable to handle kernel paging request for data at
>                     address 0x5a5a5a5a5a5a5a5a
>     Kernel Version: 2.6.19-rc5
>             Status: NEW
>           Severity: normal
>              Owner: fs_cifs@kernel-bugs.osdl.org

This could be a networking bug.

>          Submitter: sqy@vnet.ibm.com
>                 CC: akpm@osdl.org,walkinair@cn.ibm.com
> 
> 
> Most recent kernel where this bug did not occur: 2.6.19-rc5

You misunderstand.  We're asking what is the most recent version of the
kernel which *did not* have this bug.

> Distribution:  SLES10 GA
> 
> Hardware Environment: IBM p-series server (POWER5+)
> 
> Software Environment: SLES10 GA + 2.6.19-rc5 
> 
> Problem Description: 
> I mount a local samba directory and run fsstress in it. Several minutes later, 
> the machine is no response and entered xmon(a debug mode in Power arch).
> 
> Dmesg as following:
> 
> CIFS VFS: close with pending writes
> CIFS VFS: No task to wake, unknown frame rcvd! NumMids 8
> Received Data is: : dump of 37 bytes of data at 0xc00000003a6d9300
>  0000003a ff534d42 32000000 008041c0 . . . : _ S M B 2 . . . . . A _
>  00000000 00000000 00000000 0100cf08 . . . . . . . . . . . . . . _ .
>  6400422f 0a020000 d . B / .
> CIFS VFS: No task to wake, unknown frame rcvd! NumMids 
> ......
> CIFS VFS: close with pending writes.
> ......
> Unable to handle kernel paging request for data at address 0x5a5a5a5a5a5a5a5a.
> Faulting instruction address: 0xc0000000000a2e04..
> 
> xmon output:
> 
> 5:mon> e
> cpu 0x5: Vector: 300 (Data Access) at [c0000000075b7470]
>     pc: c0000000000a2e04: .put_page+0x2c/0x16c
>     lr: c00000000042f238: .skb_release_data+0x84/0xe4
>     sp: c0000000075b76f0
>    msr: 8000000000009032
>    dar: 5a5a5a5a5a5a5a5a
>  dsisr: 40000000
>   current = 0xc000000003000ad0
>   paca    = 0xc00000000062ce00
>     pid   = 4419, comm = syslog-ng
> 5:mon> t
> [c0000000075b7790] c00000000042f238 .skb_release_data+0x84/0xe4
> [c0000000075b7820] c00000000042ef04 .kfree_skbmem+0x20/0xd4
> [c0000000075b78a0] c000000000431c48 .skb_free_datagram+0x14/0x28
> [c0000000075b7920] c0000000004a7018 .unix_dgram_recvmsg+0x238/0x294
> [c0000000075b7a10] c000000000427b4c .sock_recvmsg+0xd0/0x110
> [c0000000075b7c10] c000000000428e18 .sys_recvfrom+0xcc/0x14c
> [c0000000075b7d90] c00000000044784c .compat_sys_socketcall+0x194/0x214
> [c0000000075b7e30] c000000000008724 syscall_exit+0x0/0x40
> --- Exception: c01 (System Call) at 0000000007edffdc
> SP (fa4df720) is in userspace
> 5:mon> r
> R00 = c00000000042f238   R16 = 0000000010020000
> R01 = c0000000075b76f0   R17 = 0000000010020000
> R02 = c000000000848180   R18 = 0000000010010000
> R03 = 5a5a5a5a5a5a5a5a   R19 = 0000000000000003
> R04 = 0000000000000002   R20 = 00000000fbe5fe96
> R05 = 0000000000020002   R21 = 0000000010020000
> R06 = 0000000000000000   R22 = c000000003f184b0
> R07 = 0000000000000000   R23 = c000000003de96e8
> R08 = 3520336320633000   R24 = 0000000000000050
> R09 = c000000021f18e20   R25 = c000000003f181c8
> R10 = c0000000075bb8e8   R26 = 0000000000000040
> R11 = c000000021f18e20   R27 = c00000007b165e60
> R12 = fa4df78cfa4df788   R28 = c0000000075b7a80
> R13 = c00000000062ce00   R29 = c00000007b165e60
> R14 = 0000000000000000   R30 = c000000000662d10
> R15 = 0000000010020000   R31 = 5a5a5a5a5a5a5a5a
> pc  = c0000000000a2e04 .put_page+0x2c/0x16c
> lr  = c00000000042f238 .skb_release_data+0x84/0xe4
> msr = 8000000000009032   cr  = 24044884
> ctr = c0000000004a7cb4   xer = 0000000020000001   trap =  300
> dar = 5a5a5a5a5a5a5a5a   dsisr = 40000000
> 
> Steps to reproduce:
> 
> 1.mkfs.ext3 /dev/sdb1
> 2.mount /dev/sdb1 /home
> 3.mkdir /home/public
> 4.add entry "public" (export directory /home/public) to /etc/samba/smb.conf, 
> then restart samba service
> 5.mount //localhost/public /mnt/test -o username=xxx,password=xxx
> 6.fsstress -l 500 -p 1000 -n 1000 -d /mnt/test
> 

I guess skb_release_data() ran off the end of the ->frags array and passed
uninitialised, kmalloced data to put_page().

It's a pity that you're running both samba and the CIFS client on the same
machine.  If you were to run them on two separate machines across the
network then we might be able to eliminate CIFS.

But it does look like CIFS is involved.
