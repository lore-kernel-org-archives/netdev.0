From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v5 8/9] xen-netback: Timeout packets in RX path
Date: Mon, 20 Jan 2014 22:12:33 +0000
Message-ID: <20140120221233.GB5058@zion.uk.xensource.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
 <1390253069-25507-9-git-send-email-zoltan.kiss@citrix.com>
 <20140120220348.GA5058@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140120220348.GA5058@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 20, 2014 at 10:03:48PM +0000, Wei Liu wrote:
[...]
> 
> You beat me to this. Was about to reply to your other email. :-)
> 
> It's also worth mentioning that DIV_ROUND_UP part is merely estimation,
> as you cannot possible know the maximum / miminum queue length of all
> other vifs (as they can be changed during runtime). In practice most
> users will stick with the default, but some advanced users might want to
> tune this value for individual vif (whether that's a good idea or not is
> another topic).
> 
> So, in order to convince myself this is safe. I also did some analysis
> on the impact of having queue length other than default value.  If
> queue_len < XENVIF_QUEUE_LENGTH, that means you can queue less packets
> in qdisc than default and drain it faster than calculated, which is
> safe. On the other hand if queue_len > XENVIF_QUEUE_LENGTH, it means
> actually you need more time than calculated. I'm in two minded here. The
> default value seems sensible to me but I'm still a bit worried about the
> queue_len > XENVIF_QUEUE_LENGTH case.
> 
> An idea is to book-keep maximum tx queue len among all vifs and use that
> to calculate worst scenario.
> 

And unfortunately there doesn't seem to be a way to know when tx queue
length is changed! So this approach won't work. :-(

Wei.
