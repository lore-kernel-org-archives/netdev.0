From: "Justin T. Gibbs" <gibbs@scsiguy.com>
Subject: Re: [Xen-devel] [PATCH 0001/001] xen: multi page ring support for
	block devices
Date: Wed, 14 Mar 2012 11:17:50 -0600
Message-ID: <96ED0F5B-AE7D-4C8E-A8E1-D386B2DED212@scsiguy.com>
References: <1330701099-18281-1-git-send-email-santoshprasadnayak@gmail.com>
	<7914B38A4445B34AA16EB9F1352942F1010A1FA12364@SJCPMAILBOX01.citrite.net>
	<4F55DA3E0200007800076916@nat28.tlf.novell.com>
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: "jeremy@goop.org" <jeremy@goop.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"waldi@debian.org" <waldi@debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"joe.jin@oracle.com" <joe.jin@oracle.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"weiyi.huang@gmail.com" <weiyi.huang@gmail.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Santosh Jodh <Santosh.Jodh@citrix.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"lersek@red
To: Jan Beulich <JBeulich@suse.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4F55DA3E0200007800076916@nat28.tlf.novell.com>
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

On Mar 6, 2012, at 1:34 AM, Jan Beulich wrote:

>>>> On 05.03.12 at 22:49, Santosh Jodh <Santosh.Jodh@citrix.com> wrote:

=85

>> +       }
>> +
>>        /* Create shared ring, alloc event channel. */
>>        err =3D setup_blkring(dev, info);
>>        if (err)
>> @@ -889,12 +916,35 @@ again:
>>                goto destroy_blkring;
>>        }
>> =

>> -       err =3D xenbus_printf(xbt, dev->nodename,
>> -                           "ring-ref", "%u", info->ring_ref);
>> -       if (err) {
>> -               message =3D "writing ring-ref";
>> -               goto abort_transaction;
>> +       if (legacy_backend) {
> =

> Why not use the simpler interface always when info->ring_order =3D=3D 0?

Because, as I just found out today via a FreeBSD bug report, that's
not how XenServer works.  If the front-end publishes "ring-page-order",
the backend assumes the "ring-refNN" XenStore nodes are in effect,
even if the order is 0.

I'm working on a documentation update for blkif.h now.

<sigh>

--
Justin
