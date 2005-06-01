From: Trent Jaeger <jaegert@us.ibm.com>
Subject: Re: [PATCH 2/2] Resend: LSM-IPSec Networking Hooks
Date: Wed, 1 Jun 2005 09:59:40 -0400
Message-ID: <OF8ACE890D.AD8A1444-ON85257013.004CC6F4-85257013.004CE047@us.ibm.com>
References: <Xine.LNX.4.44.0505310006060.28060-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 004CDF1985257013_="
Cc: chrisw@osdl.org, latten@austin.ibm.com, netdev@oss.sgi.com,
        sds@tycho.nsa.gov, serue@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Xine.LNX.4.44.0505310006060.28060-100000@thoron.boston.redhat.com>
To: James Morris <jmorris@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--=_alternative 004CDF1985257013_=
Content-Type: text/plain; charset="US-ASCII"

OK.

Thanks for the detailed comments. 

I will review and get back with comments and mods (probably next week).

Regards,
Trent.
------------------------------------------------------------
Trent Jaeger
IBM T.J. Watson Research Center
19 Skyline Drive, Hawthorne, NY 10532
(914) 784-7225, FAX (914) 784-7225




James Morris <jmorris@redhat.com>
05/31/2005 12:15 AM
 
        To:     Trent Jaeger/Watson/IBM@IBMUS
        cc:     netdev@oss.sgi.com, <chrisw@osdl.org>, 
serue@us.ltcfwd.linux.ibm.com, <latten@austin.ibm.com>, 
<sds@tycho.nsa.gov>
        Subject:        Re: [PATCH 2/2] Resend: LSM-IPSec Networking Hooks


On Tue, 17 May 2005, jaegert wrote:

Ok, my last review in this iteration.

> @@ -984,6 +1029,13 @@ static struct xfrm_state * pfkey_msg2xfr
>                x->lft.soft_add_expires_seconds = 
lifetime->sadb_lifetime_addtime;
>                x->lft.soft_use_expires_seconds = 
lifetime->sadb_lifetime_usetime;
>        }
> +
> +       sec_ctx = (struct sadb_x_sec_ctx *) 
ext_hdrs[SADB_X_EXT_SEC_CTX-1];
> +       if (sec_ctx != NULL) {
> +               if (security_xfrm_state_alloc(x, sec_ctx))
> +                       goto out;

You should propagate the return value of security_xfrm_state_alloc() here
by assigning it to err.

> -selinux-y := avc.o hooks.o selinuxfs.o netlink.o nlmsgtab.o
> +selinux-y := avc.o hooks.o selinuxfs.o netlink.o nlmsgtab.o nethooks.o

What about making nethooks.o (or whatever it'll be called) conditionally
compiled via CONFIG_SECURITY_NETWORK_XFRM ? (see netif.o)


> + * ISSUES:
> + *   1. Caching packets, so they are not dropped during negotiation

This needs to be done for IPsec in general, not sure what the status is.

> + *   2. Emulating a reasonable SO_PEERSEC across machines

This may not be too difficult if we limit this to connected TCP sockets.

> + *   3. Testing sk_policy setting with context

What does this mean?


Overall, this looks like a really good approach to the problem.


- James
--
James Morris
<jmorris@redhat.com>




--=_alternative 004CDF1985257013_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="sans-serif">OK.</font>
<br>
<br><font size=2 face="sans-serif">Thanks for the detailed comments. &nbsp;</font>
<br>
<br><font size=2 face="sans-serif">I will review and get back with comments
and mods (probably next week).</font>
<br>
<br><font size=2 face="sans-serif">Regards,</font>
<br><font size=2 face="sans-serif">Trent.</font>
<br><font size=2 face="sans-serif">------------------------------------------------------------<br>
Trent Jaeger<br>
IBM T.J. Watson Research Center<br>
19 Skyline Drive, Hawthorne, NY 10532<br>
(914) 784-7225, FAX (914) 784-7225</font>
<br>
<br>
<br>
<table width=100%>
<tr valign=top>
<td>
<td><font size=1 face="sans-serif"><b>James Morris &lt;jmorris@redhat.com&gt;</b></font>
<p><font size=1 face="sans-serif">05/31/2005 12:15 AM</font>
<td><font size=1 face="Arial">&nbsp; &nbsp; &nbsp; &nbsp; </font>
<br><font size=1 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; To:
&nbsp; &nbsp; &nbsp; &nbsp;Trent Jaeger/Watson/IBM@IBMUS</font>
<br><font size=1 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; cc:
&nbsp; &nbsp; &nbsp; &nbsp;netdev@oss.sgi.com, &lt;chrisw@osdl.org&gt;,
serue@us.ltcfwd.linux.ibm.com, &lt;latten@austin.ibm.com&gt;, &lt;sds@tycho.nsa.gov&gt;</font>
<br><font size=1 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; Subject:
&nbsp; &nbsp; &nbsp; &nbsp;Re: [PATCH 2/2] Resend: LSM-IPSec Networking
Hooks</font></table>
<br>
<br>
<br><font size=2><tt>On Tue, 17 May 2005, jaegert wrote:<br>
</tt></font>
<br><font size=2><tt>Ok, my last review in this iteration.<br>
</tt></font>
<br><font size=2><tt>&gt; @@ -984,6 +1029,13 @@ static struct xfrm_state
* pfkey_msg2xfr<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;x-&gt;lft.soft_add_expires_seconds
= lifetime-&gt;sadb_lifetime_addtime;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;x-&gt;lft.soft_use_expires_seconds
= lifetime-&gt;sadb_lifetime_usetime;<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp;}<br>
&gt; +<br>
&gt; + &nbsp; &nbsp; &nbsp; sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];<br>
&gt; + &nbsp; &nbsp; &nbsp; if (sec_ctx != NULL) {<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (security_xfrm_state_alloc(x,
sec_ctx))<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
&nbsp; goto out;<br>
</tt></font>
<br><font size=2><tt>You should propagate the return value of security_xfrm_state_alloc()
here<br>
by assigning it to err.<br>
</tt></font>
<br><font size=2><tt>&gt; -selinux-y := avc.o hooks.o selinuxfs.o netlink.o
nlmsgtab.o<br>
&gt; +selinux-y := avc.o hooks.o selinuxfs.o netlink.o nlmsgtab.o nethooks.o<br>
</tt></font>
<br><font size=2><tt>What about making nethooks.o (or whatever it'll be
called) conditionally<br>
compiled via CONFIG_SECURITY_NETWORK_XFRM ? (see netif.o)<br>
</tt></font>
<br>
<br><font size=2><tt>&gt; + * ISSUES:<br>
&gt; + * &nbsp; 1. Caching packets, so they are not dropped during negotiation<br>
</tt></font>
<br><font size=2><tt>This needs to be done for IPsec in general, not sure
what the status is.<br>
</tt></font>
<br><font size=2><tt>&gt; + * &nbsp; 2. Emulating a reasonable SO_PEERSEC
across machines<br>
</tt></font>
<br><font size=2><tt>This may not be too difficult if we limit this to
connected TCP sockets.<br>
</tt></font>
<br><font size=2><tt>&gt; + * &nbsp; 3. Testing sk_policy setting with
context<br>
</tt></font>
<br><font size=2><tt>What does this mean?<br>
</tt></font>
<br>
<br><font size=2><tt>Overall, this looks like a really good approach to
the problem.<br>
</tt></font>
<br>
<br><font size=2><tt>- James<br>
--<br>
James Morris<br>
&lt;jmorris@redhat.com&gt;<br>
</tt></font>
<br>
<br>
<br>
--=_alternative 004CDF1985257013_=--
