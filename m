From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC] [NETFILTER]: Fix invalid module autoloading by
 splitting iptable_nat
Date: Sun, 25 Sep 2005 18:26:28 +0200
Message-ID: <4336CFB4.6060806@trash.net>
References: <20050925150755.GK731@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@sunbeam.de.gnumonks.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050925150755.GK731@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> Hi Patrick, Dave,
> 
> I think we really need a solution for the last (known) remaining
> dependency problem with 2.6.14.  Please see the description
> below.  I _think_ the patch is fine, at least I couldn't find any case
> where we could leak anything by splitting the code in two modules.
> 
> There's a slight semantic change, though.  If the user unloads
> iptable_nat, all existing connections (including their configured NAT
> mappings) will continue to work.  Only when ip_nat.ko is unloaded, the
> NAT mappings are evicted from the conntrack table.  I like it that way,
> since it's logical.

I agree, its more logical than having the table and the conntrack
part in one module.
