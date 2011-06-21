From: Mitch Bradley <wmb-D5eQfiDGL7eakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Tue, 21 Jun 2011 09:04:33 -1000
Message-ID: <4E00EB41.9080606@firmworks.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
	<20110618161934.GH8195@ponder.secretlab.ca>
	<20110619073000.GA23171@S2100-06.ap.freescale.net>
	<20110621135558.GB9228@S2101-09.ap.freescale.net>
	<4E00E3D2.6050602@firmworks.com>
	<BANLkTiny9xDwiUww9Ys+jQZ0SHdQATABUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Jeremy Kerr <jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <BANLkTiny9xDwiUww9Ys+jQZ0SHdQATABUA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 6/21/2011 8:42 AM, Grant Likely wrote:
> On Tue, Jun 21, 2011 at 12:32 PM, Mitch Bradley<wmb-D5eQfiDGL7eakBO8gow8eQ@public.gmane.org>  wrote:
>> I wonder if it makes sense to create a new device node "/linux-devices" to express a desired mapping from device nodes to /dev entries?  The properties could be the names of device special files and the values the corresponding node phandles.
>
> I've been trying /really/ hard to avoid doing something like that
> because a lot of the time the desired Linux dev name is a
> implementation detail, and a potentially unstable one at that.  If
> Linux requires certain devices to have certain names because that is
> how it hooks up clocks (which is the current situation on some
> platforms), then I'd rather have Linux encode a lookup of the
> preferred name, at least until the that particular implementation
> detail goes away.
>
> As for enumerating devices, I don't think this is a Linux-specific
> thing.  In this case it is entirely reasonable to want to say /this
> node/ is the second serial port, and /that node/ is the third, which
> is information needed regardless of the client OS.


This reminds me a little of the "slot-names" property defined by the PCI 
bus binding.  It was intended to correlate PCI device numbers with the 
corresponding externally-visible labeling of the slot, so that error 
messages could identify a slot using a name that had some meaning to a user.

The notion of "first" and "second" is, of course, rather difficult to 
define precisely.  What aspect of the device establishes the order?

The "slot-names" property was useful for systems from e.g. Sun, where 
one vendor controlled the whole system rollup.  It was almost useless 
for cases where the one vendor supplied the motherboard and others put 
it in various cases.

>
> g.
>
>
