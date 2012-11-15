From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Thu, 15 Nov 2012 17:02:10 +0800
Message-ID: <50A4AF92.20206@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>  <20121115074057.GO8912@reaktio.net> <50A4AA06.8080900@oracle.com> <1352969519.3499.30.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?UGFzaSBLw6Rya2vDpGluZW4=?= <pasik@iki.fi>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40734 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932435Ab2KOJCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 04:02:24 -0500
In-Reply-To: <1352969519.3499.30.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-15 16:51, Ian Campbell wrote:
> On Thu, 2012-11-15 at 08:38 +0000, ANNIE LI wrote:
>> On 2012-11-15 15:40, Pasi K=C3=A4rkk=C3=A4inen wrote:
>>> Hello,
>>>
>>> On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
>>>> This patch implements persistent grants for xen-netfront/netback. =
This
>>>> mechanism maintains page pools in netback/netfront, these page poo=
ls is used to
>>>> save grant pages which are mapped. This way improve performance wh=
ich is wasted
>>>> when doing grant operations.
>>>>
>>>> Current netback/netfront does map/unmap grant operations frequentl=
y when
>>>> transmitting/receiving packets, and grant operations costs much cp=
u clock. In
>>>> this patch, netfront/netback maps grant pages when needed and then=
 saves them
>>>> into a page pool for future use. All these pages will be unmapped =
when
>>>> removing/releasing the net device.
>>>>
>>> Do you have performance numbers available already? with/without per=
sistent grants?
>> I have some simple netperf/netserver test result with/without persis=
tent
>> grants,
>>
>> Following is result of with persistent grant patch,
>> Guests, Sum,      Avg,     Min,     Max
>>    1,  15106.4,  15106.4, 15106.36, 15106.36
>>    2,  13052.7,  6526.34,  6261.81,  6790.86
>>    3,  12675.1,  6337.53,  6220.24,  6454.83
>>    4,  13194,  6596.98,  6274.70,  6919.25
> Are these pairs of guests or individual ones?

They are pairs of guests.

>
> I think the really interesting cases are when you get up to larger
> numbers of guests, aren't they?
Right.
> ISTR that for blkio things got most
> interesting WRT persistent grants at the dozens of guests stage. Do y=
ou
> have any numbers for those?
No, I will run more test with more gusets.
>
> Have you run any tests other than netperf?
No, I didn't.
>
> Do you have numbers for a a persistent capable backend with a
> non-persistent frontend and vice versa?
I did it, but the test only runs with 4 guests too=EF=BC=8Cwill test wi=
th more=20
guests.

Thanks
Annie
>
>
>>
>> Following are result of without persistent patch
>>
>> Guests, Sum,     Avg,    Min,        Max
>>    1,  10864.1,  10864.1, 10864.10, 10864.10
>>    2,  10898.5,  5449.24,  4862.08,  6036.40
>>    3,  10734.5,  5367.26,  5261.43,  5473.08
>>    4,  10924,    5461.99,  5314.84,  5609.14
>
