From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPV6: kill in6_u.u6_addrX
Date: Wed, 11 Feb 2004 22:03:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFE6A4DD6C.ACB3D0B4-ON88256E38.001F6E3F-88256E38.0020FDCB@us.ibm.com>
References: <20040212.140022.128605177.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4ABDF8CE8AF8f9e8a93df938690918c07BBE4ABDF8CE8AF"
Cc: davem@redhat.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040212.140022.128605177.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4ABDF8CE8AF8f9e8a93df938690918c07BBE4ABDF8CE8AF
Content-type: text/plain; charset=US-ASCII






> There're still two in6_u.u6_addrX in the tree.
> (I've grep'ed the tree.)

These are in-kernel only, but for application use
RFC 3493 only defines s6_addr (u_char [16]). Assuming
XNS only defines s6_addr and not the others too, then
if we want the in-kernel field names to match the external
field names, and if we want the external field names
to be compliant with other API standards...

Then, don't these names need to start with "_". As #defines,
they pollute the global namespace and don't follow the
naming conventions for public exported symbols. Unless
they've been added in later standards revisions, a
portable program should be able to use a variable name
of "s6_addr32", but can't on Linux.

Not related to what you're trying to fix, and I haven't
checked if more recent standards have defined them, but
if not, me might want to look at changing these to

#define _s6_addr32      _S6_un._s6_u32

[same namespace issue applies to the union tag, too]

                  +-DLS
--0__=07BBE4ABDF8CE8AF8f9e8a93df938690918c07BBE4ABDF8CE8AF
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>&gt; There're still two in6_u.u6_addrX in the tree.<br>
&gt; (I've grep'ed the tree.)<br>
</tt><br>
<tt>These are in-kernel only, but for application use</tt><br>
<tt>RFC 3493 only defines s6_addr (u_char [16]). Assuming</tt><br>
<tt>XNS only defines s6_addr and not the others too, then</tt><br>
<tt>if we want the in-kernel field names to match the external</tt><br>
<tt>field names, and if we want the external field names</tt><br>
<tt>to be compliant with other API standards...</tt><br>
<br>
<tt>Then, don't these names need to start with &quot;_&quot;. As #defines,</tt><br>
<tt>they pollute the global namespace and don't follow the</tt><br>
<tt>naming conventions for public exported symbols. Unless</tt><br>
<tt>they've been added in later standards revisions, a</tt><br>
<tt>portable program should be able to use a variable name</tt><br>
<tt>of &quot;s6_addr32&quot;, but can't on Linux.</tt><br>
<br>
<tt>Not related to what you're trying to fix, and I haven't</tt><br>
<tt>checked if more recent standards have defined them, but</tt><br>
<tt>if not, me might want to look at changing these to</tt><br>
<br>
<tt>#define _s6_addr32	_S6_un._s6_u32</tt><br>
<br>
<tt>[same namespace issue applies to the union tag, too]</tt><br>
<br>
<tt>			+-DLS</tt><br>
</body></html>
--0__=07BBE4ABDF8CE8AF8f9e8a93df938690918c07BBE4ABDF8CE8AF--
