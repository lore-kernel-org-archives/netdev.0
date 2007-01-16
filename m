From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Bugme-new] [Bug 7832] New: if i use iproute2 for network balancing
Date: Tue, 16 Jan 2007 14:48:20 -0800
Message-ID: <45AD5634.4030109@candelatech.com>
References: <200701161113.l0GBDZPW005410@fire-2.osdl.org> <20070116135524.e0e39e5b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chris Wedgwood <cw@f00f.org>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, gclarkx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33730 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbXAPWtZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 17:49:25 -0500
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20070116135524.e0e39e5b.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
>> On Tue, 16 Jan 2007 03:13:35 -0800 bugme-daemon@bugzilla.kernel.org wrote:
>> http://bugzilla.kernel.org/show_bug.cgi?id=7832
>>
>>            Summary: if i use iproute2 for network balancing
>>     Kernel Version: 2.6.19.1
>>             Status: NEW
>>           Severity: normal
>>              Owner: acme@conectiva.com.br
>>          Submitter: gclarkx@gmail.com
>>
>>
>> "Fedora Core4
>> Intel P4 2,4
>>
>> /sbin/ip route change default equalize nexthop dev ppp0 nexthop dev ppp1
>> /sbin/ip route flush cache

The backtrace for this one looks very similar to the IP locking
bug I reported recently.  A fix has gone into the various trees
for this problem as far as I know.

Thanks,
Ben


>> "
>>
>>
>> Jan 16 13:00:21 server kernel: Oops: 0000 [#1]
>> Jan 16 13:00:21 server kernel: SMP
>> Jan 16 13:00:21 server kernel: CPU:    1
>> Jan 16 13:00:21 server kernel: EIP:    0060:[<c02cabb7>]    Not tainted VLI
>> Jan 16 13:00:21 server kernel: EFLAGS: 00010202   (2.6.19.1 #2)
>> Jan 16 13:00:21 server kernel: EIP is at __ip_route_output_key+0x4a7/0xc99
>> Jan 16 13:00:21 server kernel: eax: 0000002c   ebx: c0c46080   ecx: 00000001   
>> e                                                                             
>> dx: 00fe7d01
>> Jan 16 13:00:21 server kernel: esi: 00000000   edi: da6a3800   ebp: dd24fd68   
>> e                                                                             
>> sp: dd24fc58
>> Jan 16 13:00:21 server kernel: ds: 007b   es: 007b   ss: 0068
>> Jan 16 13:00:21 server kernel: Process cupsd (pid: 3581, ti=dd24e000 
>> task=de8be5                                                                    
>>          70 task.ti=dd24e000)
>> Jan 16 13:00:21 server kernel: Stack: da4ce800 00000001 c03deb10 0000000a 
>> dd24fd                                                                         
>>     b0 00000068 00000000 00000000
>> Jan 16 13:00:21 server kernel: c0c46080 02000246 da4c0e80 c011f400 da4ce800 
>> 0000                                                                           
>>   0000 da9e5980 da6a3800
>> Jan 16 13:00:21 server kernel: 90000000 c045e140 da3f2c80 da3f2c80 da3f2c80 
>> 0000                                                                           
>>   0040 c02d2e19 00000001
>> Jan 16 13:00:21 server kernel: Call Trace:
>> Jan 16 13:00:21 server kernel: [<c011f400>] __local_bh_enable+0x94/0xb3
>> Jan 16 13:00:21 server kernel: [<c02d2e19>] ip_mc_output+0x2f3/0x31e
>> Jan 16 13:00:21 server kernel: [<c02cb3bc>] ip_route_output_flow+0x13/0x57
>> Jan 16 13:00:21 server kernel: [<c02ea3e4>] udp_sendmsg+0x2bb/0x537
>> Jan 16 13:00:21 server kernel: [<c02af221>] skb_copy_datagram_iovec+0x53/0x1dc
>> Jan 16 13:00:21 server kernel: [<c02efb74>] inet_sendmsg+0x3b/0x45
>> Jan 16 13:00:21 server kernel: [<c02a8c75>] sock_sendmsg+0xd3/0xee
>> Jan 16 13:00:21 server kernel: [<c012b606>] autoremove_wake_function+0x0/0x35
>> Jan 16 13:00:21 server kernel: [<c0167ec2>] core_sys_select+0x1b0/0x2a7
>> Jan 16 13:00:21 server kernel: [<c02a9539>] sys_sendto+0x116/0x140
>> Jan 16 13:00:21 server kernel: [<c02a9bcd>] sys_getsockname+0x86/0xb0
>> Jan 16 13:00:21 server kernel: [<c02acae1>] skb_dequeue+0x39/0x3f
>> Jan 16 13:00:21 server kernel: [<c02ad903>] skb_queue_purge+0x11/0x17
>> Jan 16 13:00:21 server kernel: [<c02c61c9>] netlink_sock_destruct+0xe/0xe2
>> Jan 16 13:00:21 server kernel: [<c02aae38>] sk_free+0xbe/0xf3
>> Jan 16 13:00:21 server kernel: [<e08b2cc3>] rtl8139_interrupt+0x383/0x3c3 
>> [8139t                                                                         
>>     oo]
>>
>> Message from syslogd@server at Tue Jan 16 13:00:21 2007 ...
>> server kernel:  [<c0103cf5>] sysenter_past_esp+0x56/0x79
>>
>> Message from syslogd@server at Tue Jan 16 13:00:21 2007 ...
>> server kernel:  =======================
>>
>> Message from syslogd@server at Tue Jan 16 13:00:21 2007 ...
>> server kernel: Code: 24 20 00 00 00 00 c7 44 24 60 00 00 00 00 e9 19 04 00 00 
>> 0f                                                                             
>>  b6 c2 8a 4c 24 60 6b c0 2c 03 84 24 b0 00 00 00 88 8c 24 a5 00 00 00 <8b> 40 
>> 68                                                                             
>>  89 44 24 3c f0 ff 80 80 02 00 00 84 d2 74 3e 8b 44 24
>>
>> Message from syslogd@server at Tue Jan 16 13:00:21 2007 ...
>> server kernel: EIP: [<c02cabb7>] __ip_route_output_key+0x4a7/0xc99 SS:ESP 
>> 0068:d                                                                         
>>     d24fc58
>>
>> ------- You are receiving this mail because: -------
>> You are on the CC list for the bug, or are watching someone who is.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

