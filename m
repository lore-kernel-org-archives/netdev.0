From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v2 2/2] xen-netback: Grant copy the
 header instead of map and memcpy
Date: Wed, 2 Apr 2014 08:29:38 +0100
Message-ID: <1396423778.26869.61.camel@dagon.hellion.org.uk>
References: <1396278539-27639-1-git-send-email-zoltan.kiss@citrix.com>
	<1396278539-27639-2-git-send-email-zoltan.kiss@citrix.com>
	<9AAE0902D5BC7E449B7C8E4E778ABCD02B75F1@AMSPEX01CL01.citrite.net>
	<533B0BA7.6040607@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jonathan
	Davies <Jonathan.Davies@citrix.com>, Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <533B0BA7.6040607@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-04-01 at 19:55 +0100, Zoltan Kiss wrote:
> >> @@ -1389,7 +1393,7 @@ static int xenvif_tx_submit(struct xenvif
> *vif)
> >>              txp = &vif->pending_tx_info[pending_idx].req;
> >>
> >>              /* Check the remap error code. */
> >> -            if (unlikely(xenvif_tx_check_gop(vif, skb, &gop_map)))
> {
> >> +            if (unlikely(xenvif_tx_check_gop(vif, skb, &gop_map,
> >> &gop_copy))) {
> >>                      netdev_dbg(vif->dev, "netback grant
> failed.\n");
> >
> > It could have been the copy that failed. You should probably change
> the error message.
> I've changed it to "netback grant op failed.\n"

Perhaps xenvif_tx_check_gop is in a position to log something more
specific about the failure? (maybe it already does, I didn't look).

Ian.
