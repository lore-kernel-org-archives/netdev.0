From: Olaf Hering <olh@suse.de>
Subject: Re: limited number if iptable rules on 64bit hosts
Date: Wed, 2 Feb 2005 23:25:16 +0100
Message-ID: <20050202222516.GA15440@suse.de>
References: <20050202133851.GA9680@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050202133851.GA9680@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Wed, Feb 02, Olaf Hering wrote:

> 
> What buffer or sysctrl value has to change to allow more than 3445 rules
> like this (on a 64bit host with 64bit iptables)?
> 
> iptables -A FORWARD -j ACCEPT
> 
> setsockopt(3, SOL_IP, 0x40 /* IP_??? */,
> "filter\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 524368) =
> -1 ENOMEM (Cannot allocate memory)

it triggers the first -ENOMEM in
net/ipv4/netfilter/ip_tables.c:do_replace

sizeof(struct ipt_table_info)+SMP_ALIGN(tmp.size)*NR_CPUS == 67108992 bytes

128+524288*128==67108992

(sizeof(struct ipt_table_info) + (((tmp.size) + (1 << 7)-1) & ~((1 << 7)-1)) * 128)

hmm, no braces missing.
