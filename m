From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: nft 0.4, crash on list
Date: Sun, 22 Mar 2015 00:49:04 +0200
Message-ID: <74645ce188ee403b5ffcf2303046f694@visp.net.lb>
References: <fded527361344541342afa2478b5ca9a@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>, Pablo <pablo@netfilter.org>,
	Kaber <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:36878 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbbCUWtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 18:49:07 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 56AEA48021B
	for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 00:49:05 +0200 (EET)
In-Reply-To: <fded527361344541342afa2478b5ca9a@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Additionally, if i will do "nft flush table mangle" , with this table 
added i will get this:
[   42.800078] ------------[ cut here ]------------
[   42.800092] WARNING: CPU: 3 PID: 2868 at 
net/netfilter/nf_tables_api.c:4122 nft_data_uninit+0x35/0x50 
[nf_tables]()
[   42.800094] Modules linked in: nft_meta nft_chain_route_ipv4 nft_hash 
nft_rbtree nf_tables_ipv4 nf_tables nfnetlink ramoops reed_solomon 
intel_rapl iosf_mbi x86_pkg_temp_thermal intel_powerclamp coretemp 
kvm_intel kvm uas usb_storage mei_me iTCO_wdt mei iTCO_vendor_support 
lpc_ich mfd_core intel_smartconnect
[   42.800116] CPU: 3 PID: 2868 Comm: nft Not tainted 3.19.2-test #1
[   42.800118] Hardware name:                  /DH87MC, BIOS 
MCH8710H.86A.0157.2014.0530.1830 05/30/2014
[   42.800120]  ffffffffa00ea9c9 ffff8807efe97928 ffffffff81873caa 
0000000000000000
[   42.800124]  0000000000000000 ffff8807efe97968 ffffffff8104feca 
ffff8807fabc4100
[   42.800127]  ffff8807d4550800 ffff8807d817c600 ffff8807d817c690 
ffff8807fabc4200
[   42.800130] Call Trace:
[   42.800139]  [<ffffffff81873caa>] dump_stack+0x45/0x57
[   42.800146]  [<ffffffff8104feca>] warn_slowpath_common+0x8a/0xc0
[   42.800150]  [<ffffffff8104ffba>] warn_slowpath_null+0x1a/0x20
[   42.800154]  [<ffffffffa00e2665>] nft_data_uninit+0x35/0x50 
[nf_tables]
[   42.800158]  [<ffffffffa00f10e5>] nft_rbtree_destroy+0x65/0x90 
[nft_rbtree]
[   42.800162]  [<ffffffffa00e1cdb>] nft_set_destroy+0x1b/0x40 
[nf_tables]
[   42.800166]  [<ffffffffa00e6844>] nf_tables_set_destroy+0x44/0x50 
[nf_tables]
[   42.800171]  [<ffffffffa00e8af9>] nf_tables_unbind_set+0x49/0x50 
[nf_tables]
[   42.800175]  [<ffffffffa00e9076>] nft_lookup_destroy+0x16/0x20 
[nf_tables]
[   42.800179]  [<ffffffffa00e1d41>] nf_tables_rule_destroy+0x41/0x90 
[nf_tables]
[   42.800183]  [<ffffffffa00e735d>] nf_tables_commit+0x41d/0x570 
[nf_tables]
[   42.800187]  [<ffffffffa00d7a11>] nfnetlink_rcv+0x3f1/0x4bd 
[nfnetlink]
[   42.800193]  [<ffffffff817bc816>] netlink_unicast+0xf6/0x200
[   42.800196]  [<ffffffff817bcc33>] netlink_sendmsg+0x313/0x690
[   42.800201]  [<ffffffff817747ec>] do_sock_sendmsg+0x8c/0x100
[   42.800204]  [<ffffffff81773e4e>] ? copy_msghdr_from_user+0x15e/0x1f0
[   42.800207]  [<ffffffff81774de3>] ___sys_sendmsg+0x313/0x320
[   42.800214]  [<ffffffff81153b12>] ? mmap_region+0x192/0x600
[   42.800220]  [<ffffffff812e6580>] ? apparmor_capable+0x20/0x60
[   42.800224]  [<ffffffff8187b07a>] ? _raw_spin_unlock_bh+0x1a/0x20
[   42.800228]  [<ffffffff81778ed6>] ? release_sock+0x106/0x150
[   42.800232]  [<ffffffff817754c2>] __sys_sendmsg+0x42/0x80
[   42.800235]  [<ffffffff81775512>] SyS_sendmsg+0x12/0x20
[   42.800238]  [<ffffffff8187b6f6>] system_call_fastpath+0x16/0x1b
[   42.800240] ---[ end trace 905dd3f1732b3bda ]---


On 2015-03-22 00:32, Denys Fedoryshchenko wrote:
> Hi
> 
> Just attempted to use nft, and got a bit strange crash (but sure it is
> possible i am using it wrong way)
> Table that was inserted there:
> 
> FIBERNET-NAT ~ # cat /etc/nft.cfg
> #!/sbin/nft -f
> table mangle {
>         chain output            {
>                 type route hook output priority -150;
>                 meta mark set ip daddr map {
>                         1.1.1.1/32 : 1
>                 }
>         }
> }
> 
> 
> FIBERNET-NAT ~ # nft --debug all list table mangle
> Entering state 0
> Reducing stack by rule 1 (line 544):
> -> $$ = nterm input (: )
> Stack now 0
> Entering state 1
> Reading a token: --accepting rule at line 261 ("list")
> Next token is token "list" (: )
> Shifting token "list" (: )
> Entering state 19
> Reading a token: --accepting rule at line 515 (" ")
> --accepting rule at line 234 ("table")
> Next token is token "table" (: )
> Shifting token "table" (: )
> Entering state 63
> Reading a token: --accepting rule at line 515 (" ")
> --(end of buffer or a NUL)
> --accepting rule at line 486 ("mangle")
> Next token is token "string" (: )
> Reducing stack by rule 113 (line 1052):
> -> $$ = nterm family_spec (: )
> Stack now 0 1 19 63
> Entering state 34
> Next token is token "string" (: )
> Shifting token "string" (: )
> Entering state 41
> Reducing stack by rule 110 (line 1045):
>    $1 = token "string" (: )
> -> $$ = nterm identifier (: )
> Stack now 0 1 19 63 34
> Entering state 167
> Reducing stack by rule 120 (line 1063):
>    $1 = nterm family_spec (: )
>    $2 = nterm identifier (: )
> -> $$ = nterm table_spec (: )
> Stack now 0 1 19 63
> Entering state 250
> Reducing stack by rule 45 (line 752):
>    $1 = token "table" (: )
>    $2 = nterm table_spec (: )
> -> $$ = nterm list_cmd (: )
> Stack now 0 1 19
> Entering state 69
> Reducing stack by rule 19 (line 636):
>    $1 = token "list" (: )
>    $2 = nterm list_cmd (: )
> -> $$ = nterm base_cmd (: )
> Stack now 0 1
> Entering state 32
> Reading a token: --(end of buffer or a NUL)
> --EOF (start condition 0)
> Now at end of input.
> Shifting token "end of file" (: )
> Entering state 165
> Reducing stack by rule 13 (line 602):
>    $1 = nterm base_cmd (: )
>    $2 = token "end of file" (: )
> <cmdline>:1:1-17: Evaluate
> list table mangle
> ^^^^^^^^^^^^^^^^^
> 
> 
> Stack now 0 1
> Cleanup: popping nterm input (: )
> ----------------        ------------------
> |  0000000020  |        | message length |
> | 02576 | R--- |        |  type | flags  |
> |  0000000003  |        | sequence number|
> |  0000000000  |        |     port ID    |
> ----------------        ------------------
> | 00 00 00 00  |        |  extra header  |
> ----------------        ------------------
> ----------------        ------------------
> |  0000000032  |        | message length |
> | 02570 | R-A- |        |  type | flags  |
> |  0000000005  |        | sequence number|
> |  0000000000  |        |     port ID    |
> ----------------        ------------------
> | 02 00 00 00  |        |  extra header  |
> |00011|--|00001|        |len |flags| type|
> | 6d 61 6e 67  |        |      data      |       m a n g
> | 6c 65 00 00  |        |      data      |       l e
> ----------------        ------------------
> map0 mangle f
> map0 mangle 0
> ----------------        ------------------
> |  0000000044  |        | message length |
> | 02573 | R-A- |        |  type | flags  |
> |  0000000005  |        | sequence number|
> |  0000000000  |        |     port ID    |
> ----------------        ------------------
> | 02 00 00 00  |        |  extra header  |
> |00011|--|00001|        |len |flags| type|
> | 6d 61 6e 67  |        |      data      |       m a n g
> | 6c 65 00 00  |        |      data      |       l e
> |00009|--|00002|        |len |flags| type|
> | 6d 61 70 30  |        |      data      |       m a p 0
> | 00 61 6e 67  |        |      data      |        a n g
> ----------------        ------------------
> ----------------        ------------------
> |  0000000020  |        | message length |
> | 02564 | R--- |        |  type | flags  |
> |  0000000005  |        | sequence number|
> |  0000000000  |        |     port ID    |
> ----------------        ------------------
> | 02 00 00 00  |        |  extra header  |
> ----------------        ------------------
> ----------------        ------------------
> |  0000000020  |        | message length |
> | 02567 | R--- |        |  type | flags  |
> |  0000000005  |        | sequence number|
> |  0000000000  |        |     port ID    |
> ----------------        ------------------
> | 02 00 00 00  |        |  extra header  |
> ----------------        ------------------
> ip mangle output 3
>   [ payload load 1b @ network header + 9 => reg 1 ]
>   [ cmp eq reg 1 0x00000006 ]
>   [ payload load 2b @ transport header + 0 => reg 1 ]
>   [ cmp eq reg 1 0x00005000 ]
>   [ immediate reg 1 0x0100ff7f ]
>   [ meta set priority with reg 1 ]
> 
> update network layer protocol context:
>  link layer          : none
>  network layer       : ip <-
>  transport layer     : none
> 
> update transport layer protocol context:
>  link layer          : none
>  network layer       : ip
>  transport layer     : tcp <-
> 
> ip mangle output 4 3
>   [ payload load 4b @ network header + 16 => reg 1 ]
>   [ lookup reg 1 set map0 dreg 1 ]
>   [ meta set mark with reg 1 ]
> 
> Segmentation fault
