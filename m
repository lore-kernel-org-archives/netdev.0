From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [ofa-general] [PATCH] net/inet_lro: remove setting skb->ip_summed
	when not LRO-able
Date: Wed, 25 Jun 2008 14:47:25 +0300
Message-ID: <4862304D.2050306@voltaire.com>
References: <OFEBCC17DD.4CE7F0B2-ONC1257473.003ED3DA-C1257473.003EE40F@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	Vladimir Sokolovsky <vlad@mellanox.co.il>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Jan-Bernd Themann <THEMANN@de.ibm.com>, Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OFEBCC17DD.4CE7F0B2-ONC1257473.003ED3DA-C1257473.003EE40F@de.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> no, what I meant is that it is only not needed at that particular 
> place as  the packet is not handled by LRO. Without this line the 
> driver can set an individual  value for each SKB that is not 
> aggregated if wished. For example when the packet is not a valid IP 
> packet.  However, removing all ip_summed fields impacts the fragment 
> lro mode. There we have to set some value for not aggregated packets. 
> The SKBs are generated within the LRO engine. If desired (and if there 
> is HW that wants to use that) we can pass that value for each provided 
> fragment. This would add one additional paramter to the already 8 
> parameters of __lro_proc_segment. That is of course possible.
OK, understood, both points. 

Eli, lets add to this patch a comment in inet_lro.h saying that the 
value of lro_mgr->ip_summed is ignored by the core lro code for drivers 
that use the non fragmented mode. Also for the ipoib patch, lets not set 
this value.

> I think that for valid TCP/IP packets this value should always be the 
> same as the hardware either support the set ip_summed_aggr value for 
> TCP/IPv4 packets, or not. Maybe that assumption is not right, but so 
> far I haven't seen any hardware that behaves in a different way.
Yes, for TCP/IPv4 you seem to be right and here the problem was in the 
lro patch to ipoib which set this value blindly regardless of the HW 
capabilities, I asked Vlad to change this in the next version of the 
patch. As for other types of traffic, I was thinking that allowing the 
driver to set it per packet makes a better isolation between the core 
lro code to the driver, but this is not major issue.
> yes, that is possible. An increased delay is the prise of LRO :-)
>
Is there some pointer you might be able to provide on LRO benchmark for 
small packets and/or mixed small/large packet streams?

Or.
