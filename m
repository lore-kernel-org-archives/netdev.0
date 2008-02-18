From: Jan-Bernd Themann <THEMANN@de.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Mon, 18 Feb 2008 10:56:53 +0100
Message-ID: <OF64157CA2.5201AA31-ONC12573F3.003699DB-C12573F3.00369164@de.ibm.com>
References: <1203094538.8142.23.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1390534616=="
Cc: Thomas Q Klein <TKLEIN@de.ibm.com>, ossthema@linux.vnet.ibm.com,
	Greg KH <greg@kroah.com>, apw <apw@uk.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, Christoph Raisch <RAISCH@de.ibm.com>,
	Badari Pulavarty <pbadari@us.ibm.com>,
	netdev <netdev@vger.kernel.org>, tklein@linux.ibm.com
To: Dave Hansen <haveblue@us.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1203094538.8142.23.camel@nimitz.home.sr71.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--===============1390534616==
Content-Type: multipart/alternative; boundary="=_alternative 00369162C12573F3_="

This is a multipart message in MIME format.
--=_alternative 00369162C12573F3_=
Content-Type: text/plain; charset="US-ASCII"

Dave Hansen <haveblue@us.ibm.com> wrote on 15.02.2008 17:55:38:

> I've been thinking about that, and I don't think you really *need* to
> keep a comprehensive map like that. 
> 
> When the memory is in a particular configuration (range of memory
> present along with unique set of holes) you get a unique ehea_bmap
> configuration.  That layout is completely predictable.
> 
> So, if at any time you want to figure out what the ehea_bmap address for
> a particular *Linux* virtual address is, you just need to pretend that
> you're creating the entire ehea_bmap, use the same algorithm and figure
> out host you would have placed things, and use that result.
> 
> Now, that's going to be a slow, crappy linear search (but maybe not as
> slow as recreating the silly thing).  So, you might eventually run into
> some scalability problems with a lot of packets going around.  But, I'd
> be curious if you do in practice.

Up to 14 addresses translation per packet (sg_list) might be required on 
the
transmit side. On receive side it is only 1. Most packets require only 
very few
translations (1 or sometimes more)  translations. However, with more then 
700.000 
packets per second this approach does not seem reasonable from performance
perspective when memory is fragmented as you described.

> 
> The other idea is that you create a mapping that is precisely 1:1 with
> kernel memory.  Let's say you have two sections present, 0 and 100.  You
> have a high_section_index of 100, and you vmalloc() a 100 entry array.
> 
> You need to create a *CONTIGUOUS* ehea map?  Create one like this:
> 
> EHEA_VADDR->Linux Section
> 0->0
> 1->0
> 2->0
> 3->0
> ...
> 100->100
> 
> It's contiguous.  Each area points to a valid Linux memory address.
> It's also discernable in O(1) to what EHEA address a given Linux address
> is mapped.  You just have a couple of duplicate entries. 

This has a serious issues with constraint I mentions in the previous mail: 

"- MRs can have a maximum size of the memory available under linux"

The requirement is not met that the memory region must not be 
larger then the available memory for that partition. The "create MR" 
H_CALL
will fails (we tried this and discussed with FW development)


Regards,
Jan-Bernd & Christoph
--=_alternative 00369162C12573F3_=
Content-Type: text/html; charset="US-ASCII"


<br><tt><font size=2>Dave Hansen &lt;haveblue@us.ibm.com&gt; wrote on 15.02.2008
17:55:38:</font></tt>
<br>
<br><tt><font size=2>&gt; I've been thinking about that, and I don't think
you really *need* to</font></tt>
<br><tt><font size=2>&gt; keep a comprehensive map like that. &nbsp;</font></tt>
<br><tt><font size=2>&gt; </font></tt>
<br><tt><font size=2>&gt; When the memory is in a particular configuration
(range of memory</font></tt>
<br><tt><font size=2>&gt; present along with unique set of holes) you get
a unique ehea_bmap</font></tt>
<br><tt><font size=2>&gt; configuration. &nbsp;That layout is completely
predictable.</font></tt>
<br><tt><font size=2>&gt; </font></tt>
<br><tt><font size=2>&gt; So, if at any time you want to figure out what
the ehea_bmap address for</font></tt>
<br><tt><font size=2>&gt; a particular *Linux* virtual address is, you
just need to pretend that</font></tt>
<br><tt><font size=2>&gt; you're creating the entire ehea_bmap, use the
same algorithm and figure</font></tt>
<br><tt><font size=2>&gt; out host you would have placed things, and use
that result.</font></tt>
<br><tt><font size=2>&gt; </font></tt>
<br><tt><font size=2>&gt; Now, that's going to be a slow, crappy linear
search (but maybe not as</font></tt>
<br><tt><font size=2>&gt; slow as recreating the silly thing). &nbsp;So,
you might eventually run into</font></tt>
<br><tt><font size=2>&gt; some scalability problems with a lot of packets
going around. &nbsp;But, I'd</font></tt>
<br><tt><font size=2>&gt; be curious if you do in practice.</font></tt>
<br>
<br><tt><font size=2>Up to 14 addresses translation per packet (sg_list)
might be required on the</font></tt>
<br><tt><font size=2>transmit side. On receive side it is only 1. Most
packets require only very few</font></tt>
<br><tt><font size=2>translations (1 or sometimes more) &nbsp;translations.
However, with more then 700.000 </font></tt>
<br><tt><font size=2>packets per second this approach does not seem reasonable
from performance</font></tt>
<br><tt><font size=2>perspective when memory is fragmented as you described.</font></tt>
<br>
<br><tt><font size=2>&gt; </font></tt>
<br><tt><font size=2>&gt; The other idea is that you create a mapping that
is precisely 1:1 with</font></tt>
<br><tt><font size=2>&gt; kernel memory. &nbsp;Let's say you have two sections
present, 0 and 100. &nbsp;You</font></tt>
<br><tt><font size=2>&gt; have a high_section_index of 100, and you vmalloc()
a 100 entry array.</font></tt>
<br><tt><font size=2>&gt; </font></tt>
<br><tt><font size=2>&gt; You need to create a *CONTIGUOUS* ehea map? &nbsp;Create
one like this:</font></tt>
<br><tt><font size=2>&gt; </font></tt>
<br><tt><font size=2>&gt; EHEA_VADDR-&gt;Linux Section</font></tt>
<br><tt><font size=2>&gt; 0-&gt;0</font></tt>
<br><tt><font size=2>&gt; 1-&gt;0</font></tt>
<br><tt><font size=2>&gt; 2-&gt;0</font></tt>
<br><tt><font size=2>&gt; 3-&gt;0</font></tt>
<br><tt><font size=2>&gt; ...</font></tt>
<br><tt><font size=2>&gt; 100-&gt;100</font></tt>
<br><tt><font size=2>&gt; </font></tt>
<br><tt><font size=2>&gt; It's contiguous. &nbsp;Each area points to a
valid Linux memory address.</font></tt>
<br><tt><font size=2>&gt; It's also discernable in O(1) to what EHEA address
a given Linux address</font></tt>
<br><tt><font size=2>&gt; is mapped. &nbsp;You just have a couple of duplicate
entries. &nbsp;</font></tt>
<br>
<br><tt><font size=2>This has a serious issues with constraint I mentions
in the previous mail: </font></tt>
<br><tt><font size=2>&quot;- MRs can have a maximum size of the memory
available under linux&quot;</font></tt>
<br>
<br><tt><font size=2>The requirement is not met that the memory region
must not be </font></tt>
<br><tt><font size=2>larger then the available memory for that partition.
The &quot;create MR&quot; H_CALL</font></tt>
<br><tt><font size=2>will fails (we tried this and discussed with FW development)</font></tt>
<br>
<br>
<br><tt><font size=2>Regards,</font></tt>
<br><tt><font size=2>Jan-Bernd &amp; Christoph</font></tt>
--=_alternative 00369162C12573F3_=--

--===============1390534616==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1390534616==--
