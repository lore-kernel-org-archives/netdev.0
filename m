From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Tue, 10 Feb 2004 21:39:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFA69E1A86.43DC582D-ON88256E37.0016A3A7-88256E37.00195210@us.ibm.com>
References: <20040211.120234.92333563.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4A4DF8525378f9e8a93df938690918c07BBE4A4DF852537"
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040211.120234.92333563.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4A4DF8525378f9e8a93df938690918c07BBE4A4DF852537
Content-type: text/plain; charset=US-ASCII







"Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp> wrote on
02/10/2004 07:02:34 PM:

> My point is, !(skb->dev->flags & IFF_PROMISC|IFF_ALLMULTI) is likely
true.

Yes, "deliver" is set to the expression that includes the check
"!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI))" and it is likely
true, which is why the patch I sent has "if (likely(deliver)) {"
in it.

I don't understand what you're suggesting. If you aren't suggesting
that I remove the "deliver" variable (which is needed again when you
enable the "#if 0" part), then I think your suggestion is already
in the patch. Can you explain?

> And, let's concentrate on fixing the original bug:

      I put these in to clean up the code, because Dave Miller
asked me to in the first patch. He was talking about removing
"deliver," which is needed in this revision because of your comments,
but "discard" is not. The stuff within the "#if 0" may need to be
rewritten (certainly needs to be tested), but I didn't want to
leave "discard" references, or code that is definitely incorrect.
So I modified the code within the "#if 0" to also remove the
unneeded "discard".
      The host-only path doesn't need "discard" because it is
always the same as "!deliver", but the declaration should go
away or it'll result in a warning. It could be "#if 0" too, but
I didn't want to leave it as:
      int discard = 1;
      ...
      if(deliver) {
            discard=0;
      ...

because "discard" is completely pointless without any multicast
routing code, and it's unnecessary when the "#if 0" is changed
the way I did.

In other words, removing "discard" is code-cleanup, and editing
within the "#if 0" is just so it won't leave an obvious bug when
it becomes not "#if 0".

                              +-DLS
--0__=07BBE4A4DF8525378f9e8a93df938690918c07BBE4A4DF852537
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>&quot;Hideaki YOSHIFUJI&quot; &lt;yoshfuji@cerberus.hongo.wide.ad.jp&gt; wrote on 02/10/2004 07:02:34 PM:<br>
</tt><br>
<tt>&gt; My point is, !(skb-&gt;dev-&gt;flags &amp; IFF_PROMISC|IFF_ALLMULTI) is likely true.</tt><br>
<br>
<tt>Yes, &quot;deliver&quot; is set to the expression that includes the check</tt><br>
<tt>&quot;!(skb-&gt;dev-&gt;flags &amp; (IFF_PROMISC|IFF_ALLMULTI))&quot; and it is likely</tt><br>
<tt>true, which is why the patch I sent has &quot;if (likely(deliver)) {&quot;</tt><br>
<tt>in it.</tt><br>
<br>
<tt>I don't understand what you're suggesting. If you aren't suggesting</tt><br>
<tt>that I remove the &quot;deliver&quot; variable (which is needed again when you</tt><br>
<tt>enable the &quot;#if 0&quot; part), then I think your suggestion is already</tt><br>
<tt>in the patch. Can you explain?</tt><br>
<br>
<tt>&gt; And, let's concentrate on fixing the original bug:</tt><br>
<br>
<tt>	I put these in to clean up the code, because Dave Miller</tt><br>
<tt>asked me to in the first patch. He was talking about removing</tt><br>
<tt>&quot;deliver,&quot; which is needed in this revision because of your comments,</tt><br>
<tt>but &quot;discard&quot; is not. The stuff within the &quot;#if 0&quot; may need to be</tt><br>
<tt>rewritten (certainly needs to be tested), but I didn't want to</tt><br>
<tt>leave &quot;discard&quot; references, or code that is definitely incorrect.</tt><br>
<tt>So I modified the code within the &quot;#if 0&quot; to also remove the</tt><br>
<tt>unneeded &quot;discard&quot;.</tt><br>
<tt>	The host-only path doesn't need &quot;discard&quot; because it is</tt><br>
<tt>always the same as &quot;!deliver&quot;, but the declaration should go</tt><br>
<tt>away or it'll result in a warning. It could be &quot;#if 0&quot; too, but</tt><br>
<tt>I didn't want to leave it as:</tt><br>
<tt>	int discard = 1;</tt><br>
<tt>	...</tt><br>
<tt>	if(deliver) {</tt><br>
<tt>		discard=0;</tt><br>
<tt>	...</tt><br>
<br>
<tt>because &quot;discard&quot; is completely pointless without any multicast</tt><br>
<tt>routing code, and it's unnecessary when the &quot;#if 0&quot; is changed</tt><br>
<tt>the way I did.</tt><br>
<br>
<tt>In other words, removing &quot;discard&quot; is code-cleanup, and editing</tt><br>
<tt>within the &quot;#if 0&quot; is just so it won't leave an obvious bug when</tt><br>
<tt>it becomes not &quot;#if 0&quot;.<br>
</tt><br>
<tt>					+-DLS</tt></body></html>
--0__=07BBE4A4DF8525378f9e8a93df938690918c07BBE4A4DF852537--
