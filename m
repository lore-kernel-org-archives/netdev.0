From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next 3/4] bridge: Consider the Nearest
 Customer Bridge group addresses
Date: Wed, 11 Jun 2014 15:12:01 +0900
Message-ID: <5397F331.5020608@lab.ntt.co.jp>
References: <1402313687-28067-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	<1402313687-28067-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>	<20140609085243.32f88582@nehalam.linuxnetplumber.net>	<1402332351.1742.16.camel@localhost.localdomain>	<5396363E.2020501@redhat.com>	<5396AE23.80808@lab.ntt.co.jp>
	<20140610092127.5b4f528f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>, bridge@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140610092127.5b4f528f@nehalam.linuxnetplumber.net>
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

(2014/06/11 1:21), Stephen Hemminger wrote:
> On Tue, 10 Jun 2014 16:05:07 +0900
> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> 
>> (2014/06/10 7:33), Vlad Yasevich wrote:
>> ...
>>>>> Rather than special casing this around vlan filtering, I would prefer
>>>>> the code always forward these packets, or manipulate group_fwd_mask
>>>>> to allow it that way.
>>>>
>>>> These addresses must be forwarded only if the bridge is an S-VLAN
>>>> bridge. When it is a C-VLAN bridge or a .1D bridge, they may not be
>>>> forwarded. So, I don't think we can forward them always.
>>>>
>>>> Using group_fwd_mask is a bit complicated. If we use it to forward them,
>>>> user can optionally turn off forwarding ability of those addresses...
>>>> but we maybe need another information (named like group_fwd_mask_set)
>>>> that indicates which bit is set by user. (We have to set group_fwd_mask
>>>> automatically when we set vlan_proto to 88a8.)
>>>> Is this way acceptable?
>>>
>>> May be separate it into required mask and user mask.  Set required
>>> mask when this is an S-VLAN bridge.
>>
>> Sounds like a good idea.
>> I'll give it a try, thank you for your suggestion.
>>
>> Thanks,
>> Toshiaki Makita
>>
> 
> Looking again at the code.
> 
> 1. If doing vlan then it should forward frames as defined in standard
>    by default.
> 
> 2. For compatiability, and for those users doing bump-on-wire, allow
>    forwarding via group mask.
> 

Thank you for reviewing. I sent v2 and I'm thinking it can satisfy these
two.

Thanks,
Toshiaki Makita
