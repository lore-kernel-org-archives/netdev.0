From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net 1/2] ipv6: do not delete previously existing ECMP
 routes if add fails
Date: Wed, 13 May 2015 06:30:20 -0700
Message-ID: <555351EC.9050805@cumulusnetworks.com>
References: <cover.1431500953.git.mkubecek@suse.cz> <4e3d075f2be93d9655bc1372a107584368a29eab.1431500953.git.mkubecek@suse.cz> <55534389.8070307@6wind.com> <20150513124940.GB27366@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150513124940.GB27366@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/13/15, 5:49 AM, Michal Kubecek wrote:
> On Wed, May 13, 2015 at 02:28:57PM +0200, Nicolas Dichtel wrote:
>> Le 13/05/2015 11:50, Michal Kubecek a =E9crit :
>>> If adding a nexthop of an IPv6 multipath route fails, comment in
>>> ip6_route_multipath() says we are going to delete all nexthops alre=
ady
>>> added. However, current implementation deletes even the routes it
>>> hasn't even tried to add yet. For example, running
>>>
>>>    ip route add 1234:5678::/64 \
>>>        nexthop via fe80::aa dev dummy1 \
>>>        nexthop via fe80::bb dev dummy1 \
>>>        nexthop via fe80::cc dev dummy1
>>>
>>> twice results in removing all routes first command added.
>>>
>>> Limit the second (delete) run to nexthops that succeeded in the fir=
st
>>> (add) run.
>>>
>>> Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (EC=
MP)")
>>> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
>>> ---
>>>   net/ipv6/route.c | 1 +
>>>   1 file changed, 1 insertion(+)
>>>
>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>> index d3588885f097..18b92c05b541 100644
>>> --- a/net/ipv6/route.c
>>> +++ b/net/ipv6/route.c
>>> @@ -2536,6 +2536,7 @@ beginning:
>>>   				 * next hops that have been already added.
>>>   				 */
>>>   				add =3D 0;
>>> +				remaining =3D cfg->fc_mp_len - remaining;
>>>   				goto beginning;
>> Not sure to understand your fix. At the label beginning, the code is=
:
>>
>> beginning:
>>          rtnh =3D (struct rtnexthop *)cfg->fc_mp;
>>          remaining =3D cfg->fc_mp_len;
>>
>> Hence, 'remaining' will be overridden. How does your patch work?
> It does not, sorry. I'm still trying to find out what did I wrong whi=
le
> testing. I'll need to move the initialization of remaining above the
> label.
>
This looks like a similar bug i was trying to fix some time back:
http://patchwork.ozlabs.org/patch/362296/

(I am not sure if my full patch is still valid. I was thinking of=20
re-spining it sometime soon. If you are interested in trying it out,=20
please do)
