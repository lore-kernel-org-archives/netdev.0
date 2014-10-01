From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] udp: increment UDP_NO_PORTS when dropping unmatched
 multicasts
Date: Wed, 01 Oct 2014 10:51:24 -0700
Message-ID: <542C3F1C.2080108@hp.com>
References: <20141001151921.7131E29003A2@tardy> <542C23AA.6060505@oracle.com> <542C2CAB.2030501@hp.com> <542C32E6.7080106@oracle.com> <542C3A95.8050804@hp.com> <542C3D28.6050705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:59299 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbaJARv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 13:51:26 -0400
In-Reply-To: <542C3D28.6050705@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2014 10:43 AM, David L Stevens wrote:
>
>
> On 10/01/2014 01:32 PM, Rick Jones wrote:
>
>> It would be an added statistic for "ignored" UDP multicast datagrams, incremented instead of UDP_MIB_NOPORTS.  "UDP_MIB_IGNOREDMULTI" if you will.
>>
>> Similar in concept to what HP-UX NIC drivers would increment when they received a frame for which there was no bound protocol - "inbound unknown protocols" but not a drop
>> http://ptgmedia.pearsoncmg.com/images/chap1_0130428167/elementLinks/01fig16.gif
>
> I guess I'm ok with that.
>
> Ideally, it wouldn't be affected by running a sniffer, so I think best would be to increment
> NOPORTS when someone has joined the group on the interface and IGNOREDMULTI when nobody has,
> but I'm not sure it's worth the trouble to check. So I'm good with that, or IGNOREDMULTI all
> the time.


Eric -

What is your feeling?  I have a UDP_MIB_NOPORTS v2 with UDP lite, fixed 
inner_flushed and IPv6 I can post now, or I can tweak it to add an 
IGNOREDMULTI stat and use that instead of NOPORTS.  If taking the 
IGNOREDMULTI path, I'd be inclined to go with consume_skb() 
unconditionally since the philosophy would be that it is an ignored 
packet rather than a drop (similar to the recent change in ARP).

rick
