From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: Fix fib_rules compatibility breakage
Date: Tue, 20 Mar 2007 20:58:55 +0100
Message-ID: <46003CFF.8050109@trash.net>
References: <200703190046.47021.luciano@lugmen.org.ar>
	<45FE2587.3050205@trash.net> <20070319152532.GL521@postel.suug.ch>
	<45FF7D07.4040103@trash.net> <45FF8269.3000606@trash.net>
	<20070320164004.GN521@postel.suug.ch> <46001300.90804@trash.net>
	<20070320181547.GO521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, lartc@mailman.ds9a.nl
To: Thomas Graf <tgraf@suug.ch>
Return-path: <lartc-bounces@mailman.ds9a.nl>
In-Reply-To: <20070320181547.GO521@postel.suug.ch>
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
> * Patrick McHardy <kaber@trash.net> 2007-03-20 17:59
> 
>>The presence of the attributes when src_len/dst_len is non-zero
>>is only verified in fib_newrule, so this looks like it might crash
>>when something broken sets src_len/dst_len to a non-zero value
>>without actually adding the attributes.
> 
> 
> You're right, we need to validate in fib_nl_delrule() as well.
> 
> Based on Patrick's patch:
> The fib_rules netlink attribute policy introduced in 2.6.19 broke
> userspace compatibilty. When specifying a rule with "from all"
> or "to all", iproute adds a zero byte long netlink attribute,
> but the policy requires all addresses to have a size equal to
> sizeof(struct in_addr)/sizeof(struct in6_addr), resulting in a
> validation error.
> 
> Check attribute length of FRA_SRC/FRA_DST in the generic framework
> by letting the family specific rules implementation provide the
> length of an address. Report an error if address length is non
> zero but no address attribute is provided. Fix actual bug by
> checking address length for non-zero instead of relying on
> availability of attribute.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

This looks good, thanks.

Signed-off-by: Patrick McHardy <kaber@trash.net>
