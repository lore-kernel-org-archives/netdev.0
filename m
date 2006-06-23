From: "Michael Krause" <krause@cup.hp.com>
Subject: Re: [PATCH v3 1/7] AMSO1100 Low Level Driver.
Date: Fri, 23 Jun 2006 11:02:31 -0700
Message-ID: <6.2.0.14.2.20060623105755.0201e650@esmail.cup.hp.com>
References: <20060620203050.31536.5341.stgit@stevo-desktop>
 <20060620203055.31536.15131.stgit@stevo-desktop>
 <1150836226.2891.231.camel@laptopd505.fenrus.org>
 <1151070290.7808.33.camel@stevo-desktop>
 <1151070532.3204.10.camel@laptopd505.fenrus.org>
 <1151071005.7808.39.camel@stevo-desktop>
 <1151071471.3204.12.camel@laptopd505.fenrus.org>
 <20060623171457.GA3610@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="===============0544514426=="
Cc: netdev@vger.kernel.org,
	rdreier@cisco.com,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Grant Grundler" <iod00d@hp.com>,
	"Arjan van de Ven" <arjan@infradead.org>
In-Reply-To: <20060623171457.GA3610@esmail.cup.hp.com>
References: <20060620203050.31536.5341.stgit@stevo-desktop>
 <20060620203055.31536.15131.stgit@stevo-desktop>
 <1150836226.2891.231.camel@laptopd505.fenrus.org>
 <1151070290.7808.33.camel@stevo-desktop>
 <1151070532.3204.10.camel@laptopd505.fenrus.org>
 <1151071005.7808.39.camel@stevo-desktop>
 <1151071471.3204.12.camel@laptopd505.fenrus.org>
 <20060623171457.GA3610@esmail.cup.hp.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


--===============0544514426==
Content-Type: multipart/alternative;
 boundary="=====================_171097435==.ALT"
Content-Transfer-Encoding: 7bit


--=====================_171097435==.ALT
Content-Type: text/plain;
 charset=us-ascii;
 format=flowed
Content-Transfer-Encoding: 7bit

At 10:14 AM 6/23/2006, Grant Grundler wrote:
>On Fri, Jun 23, 2006 at 04:04:31PM +0200, Arjan van de Ven wrote:
> > > I thought the posted write WILL eventually get to adapter memory.  Not
> > > stall forever cached in a bridge.  I'm wrong?
> >
> > I'm not sure there is a theoretical upper bound....
>
>I'm not aware of one either since MMIO writes can travel
>across many other chips that are not constrained by
>PCI ordering rules (I'm thinking of SGI Altix...)

It is processor / coherency backplane technology specific as to the number 
of outstanding writes.  There is also no guarantee that such writes will 
hit the top of the PCI hierarchy in the order they were posted in a 
multi-core / processor system.  Hence, it is up to software to guarantee 
that ordering is preserved and to not assume anything about ordering from a 
hardware perspective.  Once a transaction hits the PCI hierarchy, then the 
PCI ordering rules apply and depending upon the transaction type and other 
rules, what is guaranteed is deterministic in nature.


> > (and if it's several msec per bridge, then you have a lot of latency
> > anyway)
>
>That's what my original concern was when I saw you point this out.
>But MMIO reads here would be expensive and many drivers tolerate
>this latency in exchange for avoiding the MMIO read in the
>performance path.

As the saying goes, MMIO Reads are "pure evil" and should be avoided at all 
costs if performance is the goal.   Even in a relatively flat I/O 
hierarchy, the additional latency is non-trivial and can lead to a 
significant loss in performance for the system.

Mike 
--=====================_171097435==.ALT
Content-Type: text/html;
 charset=us-ascii
Content-Transfer-Encoding: 7bit

<html>
<body>
<font size=3>At 10:14 AM 6/23/2006, Grant Grundler wrote:<br>
<blockquote type=cite class=cite cite="">On Fri, Jun 23, 2006 at
04:04:31PM +0200, Arjan van de Ven wrote:<br>
&gt; &gt; I thought the posted write WILL eventually get to adapter
memory.&nbsp; Not<br>
&gt; &gt; stall forever cached in a bridge.&nbsp; I'm wrong?<br>
&gt; <br>
&gt; I'm not sure there is a theoretical upper bound.... <br><br>
I'm not aware of one either since MMIO writes can travel<br>
across many other chips that are not constrained by<br>
PCI ordering rules (I'm thinking of SGI
Altix...)</font></blockquote><br>
It is processor / coherency backplane technology specific as to the
number of outstanding writes.&nbsp; There is also no guarantee that such
writes will hit the top of the PCI hierarchy in the order they were
posted in a multi-core / processor system.&nbsp; Hence, it is up to
software to guarantee that ordering is preserved and to not assume
anything about ordering from a hardware perspective.&nbsp; Once a
transaction hits the PCI hierarchy, then the PCI ordering rules apply and
depending upon the transaction type and other rules, what is guaranteed
is deterministic in nature.<br><br>
<br>
<blockquote type=cite class=cite cite=""><font size=3>&gt; (and if it's
several msec per bridge, then you have a lot of latency<br>
&gt; anyway)<br><br>
That's what my original concern was when I saw you point this out.<br>
But MMIO reads here would be expensive and many drivers tolerate<br>
this latency in exchange for avoiding the MMIO read in the<br>
performance path.</blockquote><br>
As the saying goes, MMIO Reads are &quot;pure evil&quot; and should be
avoided at all costs if performance is the goal.&nbsp;&nbsp; Even in a
relatively flat I/O hierarchy, the additional latency is non-trivial and
can lead to a significant loss in performance for the system.&nbsp;
<br><br>
Mike</font></body>
</html>

--=====================_171097435==.ALT--

--===============0544514426==
MIME-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0544514426==--
