From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter (take 2)
Date: Wed, 9 Mar 2005 20:28:37 -0800
Message-ID: <20050309202837.1adca300.davem@davemloft.net>
References: <1108314982.4662.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        rusty@rustcorp.com.au, kaber@trash.net, snort2004@mail.ru, ak@suse.de,
        bridge@osdl.org, gandalf@wlug.westbo.se, dwmw2@infradead.org,
        shemminger@osdl.org
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <1108314982.4662.2.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 13 Feb 2005 18:16:21 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> This is a second try to fix the long chain call lengths in netfilter.
> The difference with the previous patch is that I got rid of the extra
> argument. I somehow didn't see it could be done without using the 'int
> *ret2' argument.
> 
> A comment on the number of arguments to nf_hook_slow: I don't think the
> number of arguments should be decreased. For the bridge-nf code, f.e.,
> the indev argument does not equal (*pskb)->dev (this is an answer to a
> question of Rusty in the old thread).
> 
> A comment on the argument change of nf_hook_slow (sk_buff * to sk_buff
> **) and the bad influence on tail call optimization possibilities. From
> the discussion in the old thread it became clear that no tail call is
> generated for the current code. So, I don't see why this is a reason not
> to accept the patch. Furthermore, if gcc ever would become able of doing
> the current code with a tail call, it should be very easy to change the
> code back to the original. In the meantime, I think this patch is the
> best known solution.

I agree with your analysis of the situation and have applied your
patch, thanks for keeping this going Bart.
