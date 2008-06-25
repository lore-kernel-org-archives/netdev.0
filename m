From: Jan-Bernd Themann <THEMANN@de.ibm.com>
Subject: Re: [ofa-general] [PATCH] net/inet_lro: remove setting skb->ip_summed
	when not LRO-able
Date: Wed, 25 Jun 2008 13:28:05 +0200
Message-ID: <OFEBCC17DD.4CE7F0B2-ONC1257473.003ED3DA-C1257473.003EE40F@de.ibm.com>
References: <48620F34.6090901@voltaire.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0711256659=="
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	Vladimir Sokolovsky <vlad@mellanox.co.il>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <48620F34.6090901@voltaire.com>
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
--===============0711256659==
Content-Type: multipart/alternative;
	boundary="=_alternative 003EE40CC1257473_="

This is a multipart message in MIME format.
--=_alternative 003EE40CC1257473_=
Content-Type: text/plain; charset="US-ASCII"

Hi

Or Gerlitz <ogerlitz@voltaire.com> wrote on 25.06.2008 11:26:12:

> Jan-Bernd,
> 
> I understand from your response that lro_mgr->ip_summed is not needed, 
> so I guess it should removed from all other places that (eg its 
> definition and usage in inet_lro.[ch] and under drivers/net.
> 

no, what I meant is that it is only not needed at that particular place as 

the packet is not handled by LRO. Without this line the driver can set an 
individual 
value for each SKB that is not aggregated if wished. For example when the 
packet is not a valid IP packet.
However, removing all ip_summed fields impacts the fragment lro mode. 
There we have to set
some value for not aggregated packets. The SKBs are generated within the 
LRO engine.
If desired (and if there is HW that wants to use that) 
we can pass that value for each provided fragment. This would add one 
additional paramter to the already 8 parameters
of __lro_proc_segment. That is of course possible.


> Second, if lro_mgr->aggr_ip_summed is indeed needed, I tend to think it 
> need to be derived per received packet from skb->ip_summed, since the 
> kernel allows for drivers ti have different checksum offload 
> capabilities which for some drivers might be impossible to be encoded in 

> one global value (lro_mgr->aggr_ip_summed), what's your thinking here?

I think that for valid TCP/IP packets this value should always be the same
as the hardware either support the set ip_summed_aggr value for TCP/IPv4 
packets, or not.
Maybe that assumption is not right, but so far I haven't seen any hardware 
that behaves
in a different way.

> 
> Third, consider a case where the receiver gets some very small data 
> chunks (eg file/block target that has to serve lots of IOPS for some 
> clients but also large IOs for other clients), that is some senders set 
> TCP_NODELAY, etc. Now, looking in the code _lro_proc_skb() (below) and 
> doing reading some reads at the archives, my understanding is that its 
> very possible that a large set of small packets would be gathered and 
> sent up to the stack only by the consumer calling lro_flush_all in the 
> end of its NAPI poll loop. Am I correct?

yes, that is possible. An increased delay is the prise of LRO :-)

Regards,
Jan-Bernd

--=_alternative 003EE40CC1257473_=
Content-Type: text/html; charset="US-ASCII"


<br><tt><font size=2>Hi</font></tt>
<br>
<br><tt><font size=2>Or Gerlitz &lt;ogerlitz@voltaire.com&gt; wrote on
25.06.2008 11:26:12:<br>
<br>
&gt; Jan-Bernd,<br>
&gt; <br>
&gt; I understand from your response that lro_mgr-&gt;ip_summed is not
needed, <br>
&gt; so I guess it should removed from all other places that (eg its <br>
&gt; definition and usage in inet_lro.[ch] and under drivers/net.<br>
&gt; </font></tt>
<br>
<br><tt><font size=2>no, what I meant is that it is only not needed at
that particular place as </font></tt>
<br><tt><font size=2>the packet is not handled by LRO. Without this line
the driver can set an individual </font></tt>
<br><tt><font size=2>value for each SKB that is not aggregated if wished.
For example when the packet is not a valid IP packet.</font></tt>
<br><tt><font size=2>However, removing all ip_summed fields impacts the
fragment lro mode. There we have to set</font></tt>
<br><tt><font size=2>some value for not aggregated packets. The SKBs are
generated within the LRO engine.</font></tt>
<br><tt><font size=2>If desired (and if there is HW that wants to use that)
</font></tt>
<br><tt><font size=2>we can pass that value for each provided fragment.
This would add one additional paramter to the already 8 parameters</font></tt>
<br><tt><font size=2>of __lro_proc_segment. That is of course possible.</font></tt>
<br>
<br><tt><font size=2><br>
&gt; Second, if lro_mgr-&gt;aggr_ip_summed is indeed needed, I tend to
think it <br>
&gt; need to be derived per received packet from skb-&gt;ip_summed, since
the <br>
&gt; kernel allows for drivers ti have different checksum offload <br>
&gt; capabilities which for some drivers might be impossible to be encoded
in <br>
&gt; one global value (lro_mgr-&gt;aggr_ip_summed), what's your thinking
here?</font></tt>
<br>
<br><tt><font size=2>I think that for valid TCP/IP packets this value should
always be the same</font></tt>
<br><tt><font size=2>as the hardware either support the set ip_summed_aggr
value for TCP/IPv4 packets, or not.</font></tt>
<br><tt><font size=2>Maybe that assumption is not right, but so far I haven't
seen any hardware that behaves</font></tt>
<br><tt><font size=2>in a different way.</font></tt>
<br><tt><font size=2><br>
&gt; <br>
&gt; Third, consider a case where the receiver gets some very small data
<br>
&gt; chunks (eg file/block target that has to serve lots of IOPS for some
<br>
&gt; clients but also large IOs for other clients), that is some senders
set <br>
&gt; TCP_NODELAY, etc. Now, looking in the code _lro_proc_skb() (below)
and <br>
&gt; doing reading some reads at the archives, my understanding is that
its <br>
&gt; very possible that a large set of small packets would be gathered
and <br>
&gt; sent up to the stack only by the consumer calling lro_flush_all in
the <br>
&gt; end of its NAPI poll loop. Am I correct?</font></tt>
<br>
<br><tt><font size=2>yes, that is possible. An increased delay is the prise
of LRO :-)</font></tt>
<br><tt><font size=2><br>
Regards,</font></tt>
<br><tt><font size=2>Jan-Bernd<br>
</font></tt>
--=_alternative 003EE40CC1257473_=--

--===============0711256659==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0711256659==--
