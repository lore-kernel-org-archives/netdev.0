From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: MLD problems (again) [PATCH]
Date: Mon, 12 Jan 2004 10:54:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF30B7AA41.E1486043-ON88256E19.006749C8@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE48ADFF4CF588f9e8a93df938690918c07BBE48ADFF4CF58"
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Takashi Hibi <hibi665@oki.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE48ADFF4CF588f9e8a93df938690918c07BBE48ADFF4CF58
Content-type: text/plain; charset=US-ASCII





Takashi,
      The patch I sent was for 2.6.1, but it should also apply to
2.4 line kernels and fix the problem. If you have problems getting
it to apply in 2.4, let me know what version and I can provide you
a patch specific for that kernel.

                              +-DLS


Takashi Hibi <hibi665@oki.com> on 01/12/2004 03:04:48 AM

To:    David Stevens/Beaverton/IBM@IBMUS
cc:    netdev@oss.sgi.com, davem@redhat.com
Subject:    Re: MLD problems (again) [PATCH]



David,

Thank you for the patch.
But at least it doesn't solve the problem for 2.4 line kernel.
I will also test with 2.6.1 later.

Regards,
Takashi Hibi

>
>
>
>
> Takashi,
>       I believe the patch below will fix the problem you
> had with MCAST_JOIN_SOURCE_GROUP not sending a
> report. There was a typo in the source filter switching that did
> two deletes, rather than an delete and an add.
>
> Dave,
>       Although IGMPv3 didn't have any problems, this patch
> also re-arranges the order of the filter changes. I think it's cleaner
> to add the new one first and then delete the old one, rather than
> having a small window with no filter set. So, this is a bug fix for MLD
> and a code clean-up for IGMPv3.
>       This bug and patch should also apply to the 2.4 line.
>
>                         +-DLS
>
> [included in-line for viewing and as an attachment for unmangled
>       whitespace]
>
> --- linux-2.6.1/net/ipv6/mcast.c    2004-01-08 22:59:56.000000000 -0800
> +++ linux-2.6.1F1/net/ipv6/mcast.c  2004-01-11 21:06:05.000000000 -0800
> @@ -372,9 +372,9 @@
>                   goto done;
>       } else if (pmc->sfmode != omode) {
>             /* allow mode switches for empty-set filters */
> +           ip6_mc_add_src(idev, group, omode, 0, 0, 0);
>             ip6_mc_del_src(idev, group, pmc->sfmode, 0, 0, 0);
>             pmc->sfmode = omode;
> -           ip6_mc_del_src(idev, group, pmc->sfmode, 0, 0, 0);
>       }
>
>       psl = pmc->sflist;
> --- linux-2.6.1/net/ipv4/igmp.c     2004-01-08 23:00:12.000000000 -0800
> +++ linux-2.6.1F1/net/ipv4/igmp.c   2004-01-11 21:27:41.000000000 -0800
> @@ -1749,11 +1749,10 @@
>                   goto done;
>       } else if (pmc->sfmode != omode) {
>             /* allow mode switches for empty-set filters */
> +           ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, omode, 0, 0, 0);
>             ip_mc_del_src(in_dev, &mreqs->imr_multiaddr, pmc->sfmode, 0,
>                   0, 0);
>             pmc->sfmode = omode;
> -           ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, pmc->sfmode, 0,
> -                 0, 0);
>       }
>
>       psl = pmc->sflist;
>
> (See attached file: 2.6.1MLD.patch)




--0__=07BBE48ADFF4CF588f9e8a93df938690918c07BBE48ADFF4CF58
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Takashi,<br>
	The patch I sent was for 2.6.1, but it should also apply to<br>
2.4 line kernels and fix the problem. If you have problems getting<br>
it to apply in 2.4, let me know what version and I can provide you<br>
a patch specific for that kernel.<br>
<br>
					+-DLS<br>
<br>

<p><font size="2" color="#800080">To:	</font><font size="2">David Stevens/Beaverton/IBM@IBMUS</font><br>
<font size="2" color="#800080">cc:	</font><font size="2">netdev@oss.sgi.com, davem@redhat.com</font><font size="2" color="#800080"> </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">Re: MLD problems (again) [PATCH]</font><br>
<br>
<br>
<br>
<tt>David,<br>
</tt><br>
<tt>Thank you for the patch.<br>
But at least it doesn't solve the problem for 2.4 line kernel.<br>
I will also test with 2.6.1 later.<br>
</tt><br>
<tt>Regards,<br>
Takashi Hibi<br>
</tt><br>
<tt>&gt;<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt; Takashi,<br>
&gt; &nbsp; &nbsp; &nbsp; I believe the patch below will fix the problem you<br>
&gt; had with MCAST_JOIN_SOURCE_GROUP not sending a<br>
&gt; report. There was a typo in the source filter switching that did<br>
&gt; two deletes, rather than an delete and an add.<br>
&gt;<br>
&gt; Dave,<br>
&gt; &nbsp; &nbsp; &nbsp; Although IGMPv3 didn't have any problems, this patch<br>
&gt; also re-arranges the order of the filter changes. I think it's cleaner<br>
&gt; to add the new one first and then delete the old one, rather than<br>
&gt; having a small window with no filter set. So, this is a bug fix for MLD<br>
&gt; and a code clean-up for IGMPv3.<br>
&gt; &nbsp; &nbsp; &nbsp; This bug and patch should also apply to the 2.4 line.<br>
&gt;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; +-DLS<br>
&gt;<br>
&gt; [included in-line for viewing and as an attachment for unmangled<br>
&gt; &nbsp; &nbsp; &nbsp; whitespace]<br>
&gt;<br>
&gt; --- linux-2.6.1/net/ipv6/mcast.c &nbsp; &nbsp;2004-01-08 22:59:56.000000000 -0800<br>
&gt; +++ linux-2.6.1F1/net/ipv6/mcast.c &nbsp;2004-01-11 21:06:05.000000000 -0800<br>
&gt; @@ -372,9 +372,9 @@<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; goto done;<br>
&gt; &nbsp; &nbsp; &nbsp; } else if (pmc-&gt;sfmode != omode) {<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /* allow mode switches for empty-set filters */<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ip6_mc_add_src(idev, group, omode, 0, 0, 0);<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ip6_mc_del_src(idev, group, pmc-&gt;sfmode, 0, 0, 0);<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; pmc-&gt;sfmode = omode;<br>
&gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ip6_mc_del_src(idev, group, pmc-&gt;sfmode, 0, 0, 0);<br>
&gt; &nbsp; &nbsp; &nbsp; }<br>
&gt;<br>
&gt; &nbsp; &nbsp; &nbsp; psl = pmc-&gt;sflist;<br>
&gt; --- linux-2.6.1/net/ipv4/igmp.c &nbsp; &nbsp; 2004-01-08 23:00:12.000000000 -0800<br>
&gt; +++ linux-2.6.1F1/net/ipv4/igmp.c &nbsp; 2004-01-11 21:27:41.000000000 -0800<br>
&gt; @@ -1749,11 +1749,10 @@<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; goto done;<br>
&gt; &nbsp; &nbsp; &nbsp; } else if (pmc-&gt;sfmode != omode) {<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /* allow mode switches for empty-set filters */<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ip_mc_add_src(in_dev, &amp;mreqs-&gt;imr_multiaddr, omode, 0, 0, 0);<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ip_mc_del_src(in_dev, &amp;mreqs-&gt;imr_multiaddr, pmc-&gt;sfmode, 0,<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 0, 0);<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; pmc-&gt;sfmode = omode;<br>
&gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ip_mc_add_src(in_dev, &amp;mreqs-&gt;imr_multiaddr, pmc-&gt;sfmode, 0,<br>
&gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 0, 0);<br>
&gt; &nbsp; &nbsp; &nbsp; }<br>
&gt;<br>
&gt; &nbsp; &nbsp; &nbsp; psl = pmc-&gt;sflist;<br>
&gt;<br>
&gt; (See attached file: 2.6.1MLD.patch)<br>
</tt><br>
<br>
<br>
<br>
</body></html>
--0__=07BBE48ADFF4CF588f9e8a93df938690918c07BBE48ADFF4CF58--
