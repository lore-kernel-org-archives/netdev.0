From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter
Date: Thu, 27 Jan 2005 23:48:04 +0100
Message-ID: <41F96FA4.4000105@trash.net>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>	<p73zn0ccaee.fsf@verdi.suse.de>	<1105117559.11753.34.camel@baythorne.infradead.org>	<20050107100017.454ddadc@dxpl.pdx.osdl.net>	<1105133241.3375.16.camel@localhost.localdomain>	<20050118135735.4b77d38d.davem@davemloft.net>	<1106433059.4486.11.camel@localhost.localdomain>	<1106436153.20995.42.camel@tux.rsn.bth.se>	<1106484019.3376.5.camel@localhost.localdomain>	<1106496509.1085.1.camel@tux.rsn.bth.se>	<20050125220558.6e824f8a.davem@davemloft.net>	<1106730510.4041.4.camel@localhost.localdomain>	<41F82C6D.7020006@trash.net>	<20050126231801.7bf90338.davem@davemloft.net>	<41F929FA.3050800@trash.net> <20050127114726.2205b4ed.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, snort2004@mail.ru,
        rusty@rustcorp.com.au, ak@suse.de, bridge@osdl.org,
        gandalf@wlug.westbo.se, dwmw2@infradead.org, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050127114726.2205b4ed.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>In the generated asm on sparc64, invoke2() gets a tail-call
>whereas invoke() does not.  Hmmm...
>
>
Apparently support for indirect tail-calls was added to gcc 3.4.

gcc-3.3.5:
0x0000000000000000 <invoke+0>:  sub    $0x8,%rsp
0x0000000000000004 <invoke+4>:  callq  *%esi
0x0000000000000006 <invoke+6>:  add    $0x8,%rsp
0x000000000000000a <invoke+10>: retq  

gcc-3.4.4:
0x0000000000000000 <invoke+0>:  mov    %rsi,%r11
0x0000000000000003 <invoke+3>:  jmpq   *%r11d

Regards
Patrick
