From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH] Bugs in xfrm
Date: Sat, 10 Jan 2004 10:33:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFAA4F513B.EEC50DF3-ON88256E17.005EE96A@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE484DFCD6FFA8f9e8a93df938690918c07BBE484DFCD6FFA"
Cc: krkumar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE484DFCD6FFA8f9e8a93df938690918c07BBE484DFCD6FFA
Content-type: text/plain; charset=US-ASCII





> Explain to me how that won't loop forever if given a non-NULL dst?

Oops, forgot the dst = next in the loop :-)

> Next, this dst_bundle_free() thing is totally not needed as far as I can
> tell.  When dst_free() is made, the top-level of the bundle's dst gets
added
> to the garbage collection list, the garbage collection properly walks the
> children to process the whole bundle.

The garbage collector (called via __dst_free) takes dst_garbage_list and
goes through the dst->next pointer. But dst_destroy() seems to destroy
stuff
on the dst->child list (I missed the part that the first dst has a refcnt
of
zero and all others on child have refcnt of 1). So this is not needed.

> Please redo this patch and please test it this time :)

Are the other "bugs" correct :-) Or should I send separate patches this
time ?

thanks,

- KK
--0__=07BBE484DFCD6FFA8f9e8a93df938690918c07BBE484DFCD6FFA
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><font face="Courier New">&gt; Explain to me how that won't loop forever if given a non-NULL dst?<br>
</font><br>
<font face="Courier New">Oops, forgot the dst = next in the loop :-)</font><br>
<font face="Courier New"><br>
&gt; Next, this dst_bundle_free() thing is totally not needed as far as I can<br>
&gt; tell.  When dst_free() is made, the top-level of the bundle's dst gets added<br>
&gt; to the garbage collection list, the garbage collection properly walks the<br>
&gt; children to process the whole bundle.<br>
</font><br>
<font face="Courier New">The garbage collector (called via __dst_free) takes dst_garbage_list and </font><br>
<font face="Courier New">goes through the dst-&gt;next pointer. But dst_destroy() seems to destroy stuff</font><br>
<font face="Courier New">on the dst-&gt;child list (I missed the part that the first dst has a refcnt of</font><br>
<font face="Courier New">zero and all others on child have refcnt of 1). So this is not needed.</font><br>
<font face="Courier New"><br>
&gt; Please redo this patch and please test it this time :)</font><br>
<br>
<font face="Courier New">Are the other &quot;bugs&quot; correct :-) Or should I send separate patches this time ?</font><br>
<br>
<font face="Courier New">thanks,</font><br>
<br>
<font face="Courier New">- KK</font><br>
</body></html>
--0__=07BBE484DFCD6FFA8f9e8a93df938690918c07BBE484DFCD6FFA--
