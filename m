From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [Xen-devel] [PATCH 0001/001] xen: multi page ring support for
	block devices
Date: Wed, 7 Mar 2012 10:15:54 -0500
Message-ID: <CAPbh3rsrfwr+xLSa-XCnpSjfpbA5vh9wKuX0Dtj3sWFVjSPhPg@mail.gmail.com>
References: <1330701099-18281-1-git-send-email-santoshprasadnayak@gmail.com>
	<7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
	<CAPbh3rsExLtohBwVd_scYuO=GN1iZE5egQQ3x5M59YUno5Rtyw@mail.gmail.com>
	<4F5739760200007800076DA6@nat28.tlf.novell.com>
Reply-To: konrad@darnok.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3589878353877195292=="
Cc: "jeremy@goop.org" <jeremy@goop.org>, Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"waldi@debian.org" <waldi@debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, joe.jin@oracle.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>,
	Santosh Jodh <Santosh.Jodh@citrix.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	dgdegra@tycho.nsa.gov, "virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"lersek@redhat.com" <lersek@redhat.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	David Vrabel
To: Jan Beulich <JBeulich@suse.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4F5739760200007800076DA6@nat28.tlf.novell.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============3589878353877195292==
Content-Type: multipart/alternative; boundary=bcaec53d5e0bc4941604baa8a26e

--bcaec53d5e0bc4941604baa8a26e
Content-Type: text/plain; charset=ISO-8859-1

On Mar 7, 2012 4:33 AM, "Jan Beulich" <JBeulich@suse.com> wrote:
>
> >>> On 06.03.12 at 18:20, Konrad Rzeszutek Wilk <konrad@darnok.org> wrote:
> >  -> the usage of XenbusStateInitWait? Why do we introduce that? Looks
> > like a fix to something.
>
> No, this is required to get the negotiation working (the frontend must
> not try to read the new nodes until it can be certain that the backend
> populated them). However, as already pointed out in an earlier reply
> to Santosh, the way this is done here doesn't appear to allow for the
> backend to already be in InitWait state when the frontend gets
> invoked.

OK.
>
> > -> XENBUS_MAX_RING_PAGES - why 2? Why not 4? What is the optimal
> > default size for SSD usage? 16?
>
> What do SSDs have to do with a XenBus definition? Imo it's wrong (and
> unnecessary) to introduce a limit at the XenBus level at all - each driver
> can do this for itself.

The patch should mention what the benefit of multi ring is.
>
> As to the limit for SSDs in the block interface - I don't think the number
> of possibly simultaneous requests has anything to do with this. Instead,
> I'd expect the request number/size/segments extension that NetBSD
> apparently implements to possibly have an effect.

.. which sounds to me like increasing the bandwidth of the protocol. Should
be mentioned somewhere in the git description.
>
> Jan
>
>

--bcaec53d5e0bc4941604baa8a26e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p><br>
On Mar 7, 2012 4:33 AM, &quot;Jan Beulich&quot; &lt;<a href=3D"mailto:JBeul=
ich@suse.com">JBeulich@suse.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt;&gt;&gt; On 06.03.12 at 18:20, Konrad Rzeszutek Wilk &lt;<a href=
=3D"mailto:konrad@darnok.org">konrad@darnok.org</a>&gt; wrote:<br>
&gt; &gt; =A0-&gt; the usage of XenbusStateInitWait? Why do we introduce th=
at? Looks<br>
&gt; &gt; like a fix to something.<br>
&gt;<br>
&gt; No, this is required to get the negotiation working (the frontend must=
<br>
&gt; not try to read the new nodes until it can be certain that the backend=
<br>
&gt; populated them). However, as already pointed out in an earlier reply<b=
r>
&gt; to Santosh, the way this is done here doesn&#39;t appear to allow for =
the<br>
&gt; backend to already be in InitWait state when the frontend gets<br>
&gt; invoked.</p>
<p>OK.<br>
&gt;<br>
&gt; &gt; -&gt; XENBUS_MAX_RING_PAGES - why 2? Why not 4? What is the optim=
al<br>
&gt; &gt; default size for SSD usage? 16?<br>
&gt;<br>
&gt; What do SSDs have to do with a XenBus definition? Imo it&#39;s wrong (=
and<br>
&gt; unnecessary) to introduce a limit at the XenBus level at all - each dr=
iver<br>
&gt; can do this for itself.</p>
<p>The patch should mention what the benefit of multi ring is.<br>
&gt;<br>
&gt; As to the limit for SSDs in the block interface - I don&#39;t think th=
e number<br>
&gt; of possibly simultaneous requests has anything to do with this. Instea=
d,<br>
&gt; I&#39;d expect the request number/size/segments extension that NetBSD<=
br>
&gt; apparently implements to possibly have an effect.</p>
<p>.. which sounds to me like increasing the bandwidth of the protocol. Sho=
uld be mentioned somewhere in the git description.<br>
&gt;<br>
&gt; Jan<br>
&gt;<br>
&gt;<br>
</p>

--bcaec53d5e0bc4941604baa8a26e--

--===============3589878353877195292==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============3589878353877195292==--
