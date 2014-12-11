From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next] bridge: Add ability to always enable
	TSO/UFO
Date: Thu, 11 Dec 2014 11:04:44 +0900
Message-ID: <5488FBBC.2050105@lab.ntt.co.jp>
References: <1418179394-4470-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	<1418179394-4470-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<20141210.145047.1148744559031706340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20141210.145047.1148744559031706340.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 2014/12/11 4:50, David Miller wrote:
> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Date: Wed, 10 Dec 2014 11:43:14 +0900
> 
>> -	features &= ~NETIF_F_ONE_FOR_ALL;
>> +	features &= ~NETIF_F_ONE_FOR_ALL | NETIF_F_GSO_SOFTWARE;
> 
> I don't think this is the expression you intend to use.

Thank you, but this is really my intended expression.

"features &= ~NETIF_F_ONE_FOR_ALL" drops all of ONE_FOR_ALL bits
including GSO_SOFTWARE.
But I want to leave GSO_SOFTWARE bits here.

> 
> I think you meant:
> 
> 	features &= ~(NETIF_F_ONE_FOR_ALL | NETIF_F_GSO_SOFTWARE);

ONE_FOR_ALL already includes GSO_SOFTWARE.

> 
> Or:
> 
> 	features = ~NETIF_F_ONE_FOR_ALL;
> 	features |= NETIF_F_GSO_SOFTWARE;

This way, users cannot drop TSO/UFO by ethtool.

Thanks,
Toshiaki Makita
