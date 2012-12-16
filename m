From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 01:27:55 +0100
Message-ID: <20121216002755.GA11773@1984>
References: <50C4821D.5090206@gmail.com>
 <50C9B4BB.9060609@mojatatu.com>
 <50CCE961.5050204@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53096 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950Ab2LPA2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2012 19:28:00 -0500
Content-Disposition: inline
In-Reply-To: <50CCE961.5050204@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal!

On Sat, Dec 15, 2012 at 04:19:29PM -0500, Jamal Hadi Salim wrote:
> Yury,
> 
> I took a brief look and run some quick tests on ubuntu 12.04. I am going
> to be lazy and try and involve the netfilter folks.
> It seems that if you left out the args to CONNMARK (includes other
> targets like MARK etc) you will succeed - but you get default
> values.
> 
> 
> Example, the following should work for
> tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0
> action ipt -j CONNMARK \
> action mirred egress redirect dev ifb0
> 
> Here is what the output looks like when you dont pass the parameters.
> 
> -------
> j@ubuntu:~$ sudo tc filter show dev eth0 parent ffff:
> filter protocol ip pref 1 u32
> filter protocol ip pref 1 u32 fh 800: ht divisor 1
> filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt
> 0 flowid 1:15
>   match 0a000015/ffffffff at 12
> 	action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
> 	target  MARK and 0xffffffff
> 	index 2 ref 1 bind 1
> 
> filter protocol ip pref 49149 u32
> filter protocol ip pref 49149 u32 fh 804: ht divisor 1
> filter protocol ip pref 49149 u32 fh 804::800 order 2048 key ht 804
> bkt 0 flowid 1:12
>   match 00000000/00000000 at 0
> 	action order 33: tablename: mangle  hook: NF_IP_PRE_ROUTING
> 	target  CONNMARK and 0x0
> 	index 123 ref 1 bind 1
> ----------------
> 
> Pablo, Hasan Chowdhury tells me this broke after iptable 1.4.10
> Hasan also sent me a small patch to fake "xt" instead of "ipt" - but
> i think there's more than meets the eye here; some interface we are
> using to talk to xtables on user space seems to have changed.

The binary interface was broken in 1.4.11 with the guided option
parser:

commit 7299fa4b615d7f7ee12cde444266f6b31f667f9f
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sun Mar 6 15:54:58 2011 +0100

    libxt_CONNMARK: use guided option parser

You need a patch to use the new interface to stay in sync with current
iptables libraries. I'll make it for tc and send it to you.

BTW, I think it would be good if we find the way to check for
libxtables current version (see iptables/configure.ac), so you can
know that we broke binary compatibility again.

Cheers,
Pablo
