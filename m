From: Jan-Bernd Themann <THEMANN@de.ibm.com>
Subject: Re: [ofa-general] [PATCH] net/inet_lro: remove setting skb->ip_summed
	when not LRO-able
Date: Wed, 25 Jun 2008 14:10:02 +0200
Message-ID: <OFF22ABD0B.B3396141-ONC1257473.0042666B-C1257473.0042BB30@de.ibm.com>
References: <4862304D.2050306@voltaire.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0752614969=="
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	Vladimir Sokolovsky <vlad@mellanox.co.il>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <4862304D.2050306@voltaire.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Mime-version: 1.0
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--===============0752614969==
Content-Type: multipart/alternative;
	boundary="=_alternative 0042BB2EC1257473_="

This is a multipart message in MIME format.
--=_alternative 0042BB2EC1257473_=
Content-Type: text/plain; charset="US-ASCII"

Or Gerlitz <ogerlitz@voltaire.com> wrote on 25.06.2008 13:47:25:

> Jan-Bernd Themann wrote:
> > no, what I meant is that it is only not needed at that particular 
> > place as  the packet is not handled by LRO. Without this line the 
> > driver can set an individual  value for each SKB that is not 
> > aggregated if wished. For example when the packet is not a valid IP 
> > packet.  However, removing all ip_summed fields impacts the fragment 
> > lro mode. There we have to set some value for not aggregated packets. 
> > The SKBs are generated within the LRO engine. If desired (and if there 

> > is HW that wants to use that) we can pass that value for each provided 

> > fragment. This would add one additional paramter to the already 8 
> > parameters of __lro_proc_segment. That is of course possible.
> OK, understood, both points. 
> 
> Eli, lets add to this patch a comment in inet_lro.h saying that the 
> value of lro_mgr->ip_summed is ignored by the core lro code for drivers 
> that use the non fragmented mode. Also for the ipoib patch, lets not set 

> this value.
> 
> > I think that for valid TCP/IP packets this value should always be the 
> > same as the hardware either support the set ip_summed_aggr value for 
> > TCP/IPv4 packets, or not. Maybe that assumption is not right, but so 
> > far I haven't seen any hardware that behaves in a different way.
> Yes, for TCP/IPv4 you seem to be right and here the problem was in the 
> lro patch to ipoib which set this value blindly regardless of the HW 
> capabilities, I asked Vlad to change this in the next version of the 
> patch. As for other types of traffic, I was thinking that allowing the 
> driver to set it per packet makes a better isolation between the core 
> lro code to the driver, but this is not major issue.
> > yes, that is possible. An increased delay is the prise of LRO :-)
> >
> Is there some pointer you might be able to provide on LRO benchmark for 
> small packets and/or mixed small/large packet streams?



> 
> Or.
> 
> 

--=_alternative 0042BB2EC1257473_=
Content-Type: text/html; charset="US-ASCII"


<br><tt><font size=2>Or Gerlitz &lt;ogerlitz@voltaire.com&gt; wrote on
25.06.2008 13:47:25:<br>
<br>
&gt; Jan-Bernd Themann wrote:<br>
&gt; &gt; no, what I meant is that it is only not needed at that particular
<br>
&gt; &gt; place as &nbsp;the packet is not handled by LRO. Without this
line the <br>
&gt; &gt; driver can set an individual &nbsp;value for each SKB that is
not <br>
&gt; &gt; aggregated if wished. For example when the packet is not a valid
IP <br>
&gt; &gt; packet. &nbsp;However, removing all ip_summed fields impacts
the fragment <br>
&gt; &gt; lro mode. There we have to set some value for not aggregated
packets. <br>
&gt; &gt; The SKBs are generated within the LRO engine. If desired (and
if there <br>
&gt; &gt; is HW that wants to use that) we can pass that value for each
provided <br>
&gt; &gt; fragment. This would add one additional paramter to the already
8 <br>
&gt; &gt; parameters of __lro_proc_segment. That is of course possible.<br>
&gt; OK, understood, both points. <br>
&gt; <br>
&gt; Eli, lets add to this patch a comment in inet_lro.h saying that the
<br>
&gt; value of lro_mgr-&gt;ip_summed is ignored by the core lro code for
drivers <br>
&gt; that use the non fragmented mode. Also for the ipoib patch, lets not
set <br>
&gt; this value.<br>
&gt; <br>
&gt; &gt; I think that for valid TCP/IP packets this value should always
be the <br>
&gt; &gt; same as the hardware either support the set ip_summed_aggr value
for <br>
&gt; &gt; TCP/IPv4 packets, or not. Maybe that assumption is not right,
but so <br>
&gt; &gt; far I haven't seen any hardware that behaves in a different way.<br>
&gt; Yes, for TCP/IPv4 you seem to be right and here the problem was in
the <br>
&gt; lro patch to ipoib which set this value blindly regardless of the
HW <br>
&gt; capabilities, I asked Vlad to change this in the next version of the
<br>
&gt; patch. As for other types of traffic, I was thinking that allowing
the <br>
&gt; driver to set it per packet makes a better isolation between the core
<br>
&gt; lro code to the driver, but this is not major issue.<br>
&gt; &gt; yes, that is possible. An increased delay is the prise of LRO
:-)<br>
&gt; &gt;<br>
&gt; Is there some pointer you might be able to provide on LRO benchmark
for <br>
&gt; small packets and/or mixed small/large packet streams?</font></tt>
<br>
<br>
<br><tt><font size=2><br>
&gt; <br>
&gt; Or.<br>
&gt; <br>
&gt; <br>
</font></tt>
--=_alternative 0042BB2EC1257473_=--

--===============0752614969==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0752614969==--
