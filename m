From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter
Date: Thu, 27 Jan 2005 11:47:26 -0800
Message-ID: <20050127114726.2205b4ed.davem@davemloft.net>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	<p73zn0ccaee.fsf@verdi.suse.de>
	<1105117559.11753.34.camel@baythorne.infradead.org>
	<20050107100017.454ddadc@dxpl.pdx.osdl.net>
	<1105133241.3375.16.camel@localhost.localdomain>
	<20050118135735.4b77d38d.davem@davemloft.net>
	<1106433059.4486.11.camel@localhost.localdomain>
	<1106436153.20995.42.camel@tux.rsn.bth.se>
	<1106484019.3376.5.camel@localhost.localdomain>
	<1106496509.1085.1.camel@tux.rsn.bth.se>
	<20050125220558.6e824f8a.davem@davemloft.net>
	<1106730510.4041.4.camel@localhost.localdomain>
	<41F82C6D.7020006@trash.net>
	<20050126231801.7bf90338.davem@davemloft.net>
	<41F929FA.3050800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, snort2004@mail.ru,
        rusty@rustcorp.com.au, ak@suse.de, bridge@osdl.org,
        gandalf@wlug.westbo.se, dwmw2@infradead.org, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41F929FA.3050800@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 18:50:50 +0100
Patrick McHardy <kaber@trash.net> wrote:

>  From what I can see it doesn't generate tail-calls currently:

Indeed... It even doesn't do this on Sparc64 either, even for
the okfn(skb) call which I was sure it would.

It won't tail-call for function pointers for some strance reason
as exhibited by this simple test:

struct sk_buff {
	int foo;
};

int invoke(struct sk_buff *skb, int (*okfn)(struct sk_buff *))
{
	return okfn(skb);
}

extern int test_func(struct sk_buff *);

int invoke2(struct sk_buff *skb)
{
	return test_func(skb);
}

In the generated asm on sparc64, invoke2() gets a tail-call
whereas invoke() does not.  Hmmm...
