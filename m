From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [RFC] TCP congestion schedulers
Date: Fri, 18 Mar 2005 09:53:25 -0300
Message-ID: <39e6f6c705031804531c2c557f@mail.gmail.com>
References: <421CF5E5.1060606@ev-en.org> <421D30FA.1060900@ev-en.org>
	 <20050225120814.5fa77b13@dxpl.pdx.osdl.net>
	 <20050309210442.3e9786a6.davem@davemloft.net>
	 <4230288F.1030202@ev-en.org>
	 <20050310182629.1eab09ec.davem@davemloft.net>
	 <20050311120054.4bbf675a@dxpl.pdx.osdl.net>
	 <20050311201011.360c00da.davem@davemloft.net>
	 <20050314151726.532af90d@dxpl.pdx.osdl.net>
	 <20050317201231.6d575e0b.davem@davemloft.net>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, baruch@ev-en.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050317201231.6d575e0b.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2005 20:12:31 -0800, David S. Miller <davem@davemloft.net> wrote:
> On Mon, 14 Mar 2005 15:17:26 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > +/* Hook for advanced congestion control */
> > +     struct tcp_ca_type *ca_proto;
> > +#define TCP_CA_PRIV_SIZE     48
> > +     u8               *ca_priv[TCP_CA_PRIV_SIZE];
> 
> An array of 48 pointers to "u8" eh? :-)
> 
> It happens to work, but you're using too much
> space (specifically: 48 * sizeof(u8 *)) as a side effect.
> 
> Otherwise, the only comment I have is that we lose the tcp_diag
> info.  Maybe create a "tcpdiag_put" method in there so we can
> retain that.
> 
> I'm also not so religious anymore about retaining the existing
> sysctl functionality to enable/disable ca algs.

I haven't looked over this patch completely, so I may well be saying something
stupid, but if possible, please don't use the tcp/TCP prefix where you
think this
code can be used by other inet transport protocols, such as DCCP. I'll try to
review this patch this weekend to see if this is possible or if I'm on
crack now 8)

- Arnaldo
