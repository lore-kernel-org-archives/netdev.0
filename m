From: "=?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=" <yoshfuji@linux-ipv6.org>
Subject: Re: (usagi-core 16947) Re: 2.6.0: something is leaking memory
Date: Mon, 29 Mar 2004 16:43:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <02aa01c415a4$a1c9e700$d100000a@sbs2003.local>
References: <slrnbvgohn.1pb.erik@dexter.hensema.net><Pine.LNX.4.58.0401041257290.2162@home.osdl.org><slrnbvh1hd.jl6.erik@dexter.hensema.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <Administrator@oss.sgi.com>
Content-Class: urn:content-classes:message
In-Reply-To: <slrnbvh1hd.jl6.erik@dexter.hensema.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <slrnbvh1hd.jl6.erik@dexter.hensema.net> (at Sun, 4 Jan 2004 21:31:26 +0000 (UTC)), Erik Hensema <erik@hensema.net> says:

> > Can you do /proc/slabinfo too?
> 
> Sure, this is of course my currently running system, 4 days, 9:53
> uptime.
> 
> slabinfo - version: 2.0
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <batchcount> <limit> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
:
> tcp6_sock          19729  19732   1024    4    1 : tunables   54   27    0 : slabdata   4933   4933      0
:
> > Clearly the memory leak isn't in the page cache, so the most likely source 
> > is network buffers, and most likely in iptables connection tracking or 
> > similar. If you actually _use_ IPv6, then that is also more likely to have 
> > leaks just due to less testing.
> 
> I do use IPv6. I've got three active tunnels and native IPv6 over
> ethernet.
> 
> I've always had problems with nscd leaking filedescriptors, all
> IPv6 connections to my LDAP server. This started after upgrading
> suse 8.0 to 8.2 (I think the problem is in nss_ldap).
> I'm restarting nscd using a cronjob every night now. Output of
> netstat --inet6 -avpn is below. All sockets in CLOSE_WAIT are
> leaked and will go away after a nscd restart.

How about /proc/slabinfo just after restarting nss_ldap?

> The server isn't very critical, but I do need it. I'm willing to
> try some patches (or do an upgrade to -mm), but nothing to wild.
> 
> netstat --inet6 -avpn
> 
> Active Internet connections (servers and established)
> Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name   
> tcp        0      0 :::22                   :::*                    LISTEN      1208/sshd           
> tcp        0      0 :::119                  :::*                    LISTEN      1364/innd           
> tcp        0      0 :::25                   :::*                    LISTEN      1433/sendmail: acce 
> tcp        0      0 :::953                  :::*                    LISTEN      1175/named          
> tcp        0      0 ::1:6010                :::*                    LISTEN      19900/sshd          
> tcp        0      0 ::1:6011                :::*                    LISTEN      20150/sshd          
> tcp        1      0 ::1:50565               2001:888:10a1::1:389    CLOSE_WAIT  26536/nscd          
> tcp        1      0 ::1:50224               2001:888:10a1::1:389    CLOSE_WAIT  26536/nscd          
> tcp        0      0 2001:888:10a1::1:389    ::1:55936               ESTABLISHED 1145/slapd          
> tcp        1      0 ::1:50343               2001:888:10a1::1:389    CLOSE_WAIT  26536/nscd          
> tcp        1      0 ::1:50988               2001:888:10a1::1:389    CLOSE_WAIT  26536/nscd          
:

There're too many sockets in CLOSE_WAIT, but the number is very different from
"tcp6_sock."


And, what is happened when you use ipv4 in your nscd?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
