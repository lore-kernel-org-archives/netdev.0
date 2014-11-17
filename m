From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: Re: [BUG] index is out of range for nfnl_group2type[]
Date: Mon, 17 Nov 2014 11:16:17 +0300
Message-ID: <5469AED1.3000000@samsung.com>
References: <5464733B.5060505@samsung.com> <20141114174438.GA10644@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20141114174438.GA10644@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/2014 08:44 PM, Pablo Neira Ayuso wrote:
> On Thu, Nov 13, 2014 at 12:00:43PM +0300, Andrey Ryabinin wrote:
>> FYI I've spotted this:
>>
>> [  180.202810] ================================================================================
>> [  180.203600] UBSan: Undefined behaviour in ../net/netfilter/nfnetlink.c:467:28
>> [  180.204249] index 9 is out of range for type 'int [9]'
>> [  180.204697] CPU: 0 PID: 1771 Comm: trinity-main Not tainted 3.18.0-rc4-mm1+ #122
>> [  180.205365] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
>> [  180.206498]  0000000000000018 0000000000000000 0000000000000009 ffff88007bdf7da8
>> [  180.207220]  ffffffff82b0ef5f 0000000000000092 ffffffff845ae2e0 ffff88007bdf7db8
>> [  180.207887]  ffffffff8199e489 ffff88007bdf7e18 ffffffff8199ea22 0000003900000000
>> [  180.208639] Call Trace:
>> [  180.208857] dump_stack (lib/dump_stack.c:52)
>> [  180.209370] ubsan_epilogue (lib/ubsan.c:174)
>> [  180.209849] __ubsan_handle_out_of_bounds (lib/ubsan.c:400)
>> [  180.210512] nfnetlink_bind (net/netfilter/nfnetlink.c:467)
>> [  180.210986] netlink_bind (net/netlink/af_netlink.c:1483)
>> [  180.211495] SYSC_bind (net/socket.c:1541)
>> [  180.211940] ? security_socket_setsockopt (security/security.c:1208)
>> [  180.212541] ? SyS_setsockopt (net/socket.c:1920 net/socket.c:1900)
>> [  180.213057] ? SyS_write (fs/read_write.c:276 fs/read_write.c:588 fs/read_write.c:577)
>> [  180.213506] SyS_bind (net/socket.c:1527)
>> [  180.213919] system_call_fastpath (arch/x86/kernel/entry_64.S:423)
>> [  180.214479] ================================================================================
> 
> Thanks for reporting. I think the attached patch fixes this problem.
> 

Yep, It's gone away after applying your patch.

Thanks,
Andrey.

