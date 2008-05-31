From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 19:09:52 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins>
 <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1647873004-1212250192=:2657"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53906 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939AbYEaQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 12:09:59 -0400
In-Reply-To: <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1647873004-1212250192=:2657
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Thanks for reporting!

On Sat, 31 May 2008, Håkon Løvdal wrote:

> posted a few days ago are somewhat different from mine, however I believe
> this is the same problem or at least related. Just as Ingo experienced,
> netstat -p only shows PID/program as '-' for the hung connections while
> for other connections it shows the expected results.

Hmm, are the other end's processes still there? ...I'd be interested to 
know what they're doing at the moment...

> I have recently bought a new PC and have started the process of copying
> stuff from my old PC to the new PC. During this I have experienced this
> hang several times. I started copying by using tar on both ends over a ssh
> pipe but in order to eliminate possible ssh problems I also have tried tar
> over a ttcp connection which also fails. There is no obvious pattern of
> when this happens, I have experienced failures after transferring 
> 1.15GB, 51.4GB and 23.6GB.
>
> Here is the output from netstat -n -o filtered for port 22 and slightly
> edited. All the lines started with Proto == tcp and Recv-Q == 0.

...The receiving end's state would be more interesting.

> Send-Q Local Addr Foreign Addr  State       Timer
>      0 old_pc:22  new_pc:52667  ESTABLISHED keepalive (3513.93/0/0)
>      0 old_pc:22  new_pc:43825  ESTABLISHED keepalive (5467.38/0/0)
>   2896 old_pc:22  new_pc:58601  ESTABLISHED on (21020884.65/0/0)
>   4344 old_pc:22  new_pc:54105  ESTABLISHED on (21017016.33/0/0)
>   2896 old_pc:22  new_pc:34149  ESTABLISHED on (20986889.24/0/0)
> 
> The first two connections are ongoing, working, interactive ssh
> connections. The other three connections died days ago on my new PC.

Died? Do you mean that they don't exist all at the other end anymore?

> One thing that caught my eyes was these very high timer values.
> Checking the netstat source reveals that the value printed is "(double)
> time_len / HZ" and that time_len is extracted from /proc/net/tcp. While
> my CONFIG_HZ is 1000, I assume netstat has picked up HZ as 100 from
> /usr/include/asm/param.h, and then things really seems to imply that
> there is some integer overflow since 2^31 = 2147483648.

...plain /proc/net/tcp would be much nicer to read and without all such 
conversion troubles ;-).

> Looking into get_tcp4_sock in net/ipv4/tcp_ipv4.c I see that timer_expires
> is initialized with icsk->icsk_timeout for the troublesome cases. But
> here my competence to trace this further stops, so I have no idea of
> how icsk->icsk_timeout gets such high values.
>
> My old PC is currently still running with these stalled connections
> present so let me know if there is something I should try to investigate
> further.
>
> I can post output from /proc/net/tcp

For both ends that would be great.

> and my .config if you want to have a look.

Not needed I think.

> My old PC is 32 bit/Celeron single core, kernel 2.6.24,
> while my new is 64 bit/Q9300 quad core, kernel 2.6.25.3.
> The ethernet cards are the following:
> 
> 02:0d.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056
> PCI-E Gigabit Ethernet Controller (rev 12)


-- 
 i.
---696208474-1647873004-1212250192=:2657--
