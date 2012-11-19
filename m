From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: compound skb frag pages appearing in start_xmit
Date: Mon, 19 Nov 2012 16:43:04 +0100
Message-ID: <1333495676.20121119164304@eikelenboom.it>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	<1349790863.21172.4406.camel@edumazet-glaptop>
	<1349792241.21847.199.camel@zakaz.uk.xensource.com>
	<1349792847.21172.4479.camel@edumazet-glaptop>
	<1349793630.21847.208.camel@zakaz.uk.xensource.com>
	<1349863984.10070.26.camel@zakaz.uk.xensource.com>
	<1349874598.10070.39.camel@zakaz.uk.xensource.com>
	<748966751.20121010164949@eikelenboom.it>
	<1349942546.14806.7.camel@zakaz.uk.xensource.com>
	<151954917.20121011120004@eikelenboom.it>
	<1349949924.21172.8462.camel@edumazet-glaptop>
	<1349950494.14806.29.camel@zakaz.uk.xensource.com>
	<50A4540E.1010601@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Marcos E. Matsunaga" <Marcos.Matsunaga@oracle.com>,
	xen-devel <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: ANNIE LI <annie.li@oracle.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <50A4540E.1010601@oracle.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org


Thursday, November 15, 2012, 3:31:42 AM, you wrote:

> On 2012-10-11 18:14, Ian Campbell wrote:
>> On Thu, 2012-10-11 at 11:05 +0100, Eric Dumazet wrote:
>>> On Thu, 2012-10-11 at 12:00 +0200, Sander Eikelenboom wrote:
>>>
>>>> Probably due to the BUG_ON from the patch below, i changed it into a WARN_ON.
>>>> And i seem to hit it, but only in one of the guests at the moment and it triggers quite irregularly.
>>> xennet_make_frags() is able to split the skb->head in multiple page-size
>>> chunks.
>>>
>>> It should do the same for fragments
>> Right, I just want to be reproduce the issue so I can know I've fixed it
>> properly ;-)
> Hi Ian,

> I can reproduce this BUG_ON when running netperf/netserver test between 
> two domus running on the same dom0. The domu and dom0 all use v3.7-rc1.

> When I tried to rebase my persistent grant netfront/netback patch on 
> latest kernel, netperf/netserver test never succeeded. I did some test 
> to find out that v3.6-rc7 works fine, but v3.7-rc1, v3.7-rc2 and 
> v3.7-rc4 does not succeed in netperf/netserver test. So I keep my 
> persistent grant patch only based on v3.4-rc3 now.

> Konrad thought about commit 6a8ed462f16b8455eec5ae00eb6014159a6721f0 in 
> v3.7-rc1, and suggested me to test your debug patch in netfront. This 
> BUG_ON happens soon after running the netperf/netserver test case.

> Thanks
> Annie

Is there any progression with this bug (rc6 is out the door, so the release of 3.7-final seems to be eminent and this bug completely cripples any networking with guests) ?

--
Sander

>>
>> Ian.
>>
>>
>>
>>
>> _______________________________________________
>> Xen-devel mailing list
>> Xen-devel@lists.xen.org
>> http://lists.xen.org/xen-devel
