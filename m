From: Patrick McHardy <kaber@trash.net>
Subject: Re: kernel stack  trace using conntrack
Date: Thu, 18 Feb 2010 13:19:59 +0100
Message-ID: <4B7D306F.9060808@trash.net>
References: <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D04@FRSPX100.fr01.awl.atosorigin.net>	 <1266313889.3045.1.camel@edumazet-laptop>	 <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D54@FRSPX100.fr01.awl.atosorigin.net>	 <1266318928.3045.38.camel@edumazet-laptop>  <4B7A9E95.103@netfilter.org> <1266327917.3045.55.camel@edumazet-laptop> <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC905D@FRSPX100.fr01.awl.atosorigin.net> <4B7D17CE.6010805@trash.net> <4B7D1E32.6000705@netfilter.org> <4B7D215A.6060400@trash.net> <4B7D3022.9030405@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ramblewski David <David.Ramblewski@atosorigin.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B7D3022.9030405@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>>>> Pablo, please let me know whether you want me to apply this.
>>> ctnetlink_change_helper() also calls nf_ct_ext_add() for conntracks that
>>> are confirmed (in case of a helper update for an existing conntrack).
>>> That would also trigger the assertion. If we want to support helper
>>> assignation via ctnetlink for existing conntracks, we will need to add
>>> locking to the conntrack extension infrastructure to avoid races.
>>>
>>> I don't see a clear solution for this yet.
>> I see, this is indeed a problem. Since the helper is known at the
>> first event, we could restrict this to only allow manual assignment
>> for newly created conntracks. Most helpers probably can't properly
>> cope with connections not seen from the beginning anyways.
> 
> Indeed, changing the helper in the middle of the road doesn't make too
> much sense to me either. I can send you a patch for this along today,
> I'll find some spare time to do it.

Great, thanks Pablo.
