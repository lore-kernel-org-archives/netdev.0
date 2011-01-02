From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 22:46:12 +0100
Message-ID: <1294004772.5675.11.camel@wall-e>
References: <1293982286-15389-1-git-send-email-stefani@seibold.net>
	 <alpine.LNX.2.00.1101022024200.11481@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1101022024200.11481@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Sonntag, den 02.01.2011, 20:55 +0100 schrieb Jesper Juhl:
> On Sun, 2 Jan 2011, stefani@seibold.net wrote:


> > +
> > +#define VERSION	"0.71"
> 
> I personally don't think this makes much sense.
> Version numbers for individual modules tend to not get updated as the code 
> changes over the years, which make them rather meaningless.
> Since this module depends on functionallity of the kernel which it is 
> compiled with, the actual (meaningful) version of this code is that of the 
> kernel tree being compiled that includes this code. Which again makes this 
> specific version define meaningless.
> 
> So, why not save a few lines of code and get rid of this rather pointless 
> thing?
> 

I like it, it gives me a better monitoring during development which
version is currently tested.

> [...]
> > +static struct udpcp_dest *find_dest(struct sock *sk, __be32 addr, __be16 port)
> > +{
> > +	struct udpcp_dest *dest;
> > +
> > +	dest = __find_dest(sk, addr, port);
> 
> Why not
> 
> static struct udpcp_dest *find_dest(struct sock *sk, __be32 addr, __be16 port)
> {
>      struct udpcp_dest *dest =  __find_dest(sk, addr, port);
> 
> ?
I will fix it but i think this is counting peas.
 
> 
> 
> [...]
> > + * Release a routing table entry if no packed will be assembled
> 
> Don't you mean "packet" rather than "packed" here?
> 
> 
Right.

> [...]
> > + * Return true it the passed skb socket buffer is the last in the list
> 
> I believe you mean "Return true if the passed ..."
> 
Right.

> 
> [...]
> > +static void udpcp_flush_err(struct sock *sk, struct udpcp_dest *dest)
> > +{
> > +	struct inet_sock *inet = inet_sk(sk);
> > +	struct udpcp_sock *usk = udpcp_sk(sk);
> > +
> > +	if (!inet->recverr)
> > +		skb_queue_purge(&dest->xmit);
> > +	else {
> 
> CodingStyle would want this as
> 
>      if (!inet->recverr) {
>              skb_queue_purge(&dest->xmit);
>      } else {
> 
> If one branch needs {} then both should get them.
> 
./scripts/checkpatch.pl did not complain about this, so i think it is
okay.

> 
> [...]
> > +	if (!dest->xmit_last)
> > +		_udpcp_xmit(sk, dest);
> > +	else {
> > +		skb = dest->xmit_wait;
> 
> Same comment as above.
> There are more occurences of this, I'm not going to point them all out.
> 
> 
> [...]
> > +static inline void udpcp_release_sock(struct sock *sk)
> > +{
> > +	struct udpcp_sock *usk = udpcp_sk(sk);
> > +
> > +	while (usk->timeout)
> > +		udpcp_handle_timeout(sk);
> > +	release_sock(sk);
> > +        check_timeout(sk);
> 
> The line above uses spaces for indentation. It should use one tab.
> 
> 
> [...]
> > +static unsigned int udpcp_tx_queue_len(struct sock *sk, struct udpcp_dest *dest)
> > +{
> > +	struct sk_buff *skb;
> > +	unsigned int n;
> > +
> > +	n = 0;
> 
> Might as well save a few lines and make this
> 
> static unsigned int udpcp_tx_queue_len(struct sock *sk, struct udpcp_dest *dest)
> {
>      struct sk_buff *skb;
>      unsigned int n = 0;
> 
> 
> [...]
> > +static unsigned int udpcp_rx_queue_len(struct sock *sk, struct udpcp_dest *dest)
> > +{
> > +	struct sk_buff *skb;
> > +	unsigned int n;
> > +
> > +	n = 0;
> 
> Here as well
>         unsigned int n = 0;
> 
> 

I fix it in the next release.

Thanks
