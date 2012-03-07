From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 0001/001] xen: multi page ring support
	for block devices
Date: Wed, 07 Mar 2012 09:33:26 +0000
Message-ID: <4F5739760200007800076DA6@nat28.tlf.novell.com>
References: <1330701099-18281-1-git-send-email-santoshprasadnayak@gmail.com>
	<7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
	<CAPbh3rsExLtohBwVd_scYuO=GN1iZE5egQQ3x5M59YUno5Rtyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "jeremy@goop.org" <jeremy@goop.org>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"waldi@debian.org" <waldi@debian.org>,
	"joe.jin@oracle.com" <joe.jin@oracle.com>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"lersek@redhat.com" <lersek@redhat.com>,
	"dgdegra@ty
To: "Santosh Jodh" <Santosh.Jodh@citrix.com>,<konrad@darnok.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAPbh3rsExLtohBwVd_scYuO=GN1iZE5egQQ3x5M59YUno5Rtyw@mail.gmail.com>
Content-Disposition: inline
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

>>> On 06.03.12 at 18:20, Konrad Rzeszutek Wilk <konrad@darnok.org> wrote:
>  -> the usage of XenbusStateInitWait? Why do we introduce that? Looks
> like a fix to something.

No, this is required to get the negotiation working (the frontend must
not try to read the new nodes until it can be certain that the backend
populated them). However, as already pointed out in an earlier reply
to Santosh, the way this is done here doesn't appear to allow for the
backend to already be in InitWait state when the frontend gets
invoked.

> -> XENBUS_MAX_RING_PAGES - why 2? Why not 4? What is the optimal
> default size for SSD usage? 16?

What do SSDs have to do with a XenBus definition? Imo it's wrong (and
unnecessary) to introduce a limit at the XenBus level at all - each driver
can do this for itself.

As to the limit for SSDs in the block interface - I don't think the number
of possibly simultaneous requests has anything to do with this. Instead,
I'd expect the request number/size/segments extension that NetBSD
apparently implements to possibly have an effect.

Jan
