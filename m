From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: Fix fib_rules compatibility breakage
Date: Tue, 20 Mar 2007 17:59:44 +0100
Message-ID: <46001300.90804@trash.net>
References: <200703190046.47021.luciano@lugmen.org.ar>
	<45FE2587.3050205@trash.net> <20070319152532.GL521@postel.suug.ch>
	<45FF7D07.4040103@trash.net> <45FF8269.3000606@trash.net>
	<20070320164004.GN521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, lartc@mailman.ds9a.nl
To: Thomas Graf <tgraf@suug.ch>
Return-path: <lartc-bounces@mailman.ds9a.nl>
In-Reply-To: <20070320164004.GN521@postel.suug.ch>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> @@ -242,10 +239,10 @@ static int fib4_rule_compare(struct fib_
>  		return 0;
>  #endif
>  
> -	if (tb[FRA_SRC] && (rule4->src != nla_get_be32(tb[FRA_SRC])))
> +	if (frh->src_len && (rule4->src != nla_get_be32(tb[FRA_SRC])))
>  		return 0;
>  
> -	if (tb[FRA_DST] && (rule4->dst != nla_get_be32(tb[FRA_DST])))
> +	if (frh->dst_len && (rule4->dst != nla_get_be32(tb[FRA_DST])))
>  		return 0;
>  


The presence of the attributes when src_len/dst_len is non-zero
is only verified in fib_newrule, so this looks like it might crash
when something broken sets src_len/dst_len to a non-zero value
without actually adding the attributes.

Other than that it looks fine.
