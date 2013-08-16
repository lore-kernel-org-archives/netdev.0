From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2 1/3] net/usb/r8152: support aggregation
Date: Fri, 16 Aug 2013 07:54:40 +0200
Message-ID: <20130816055440.GA2458@electric-eye.fr.zoreil.com>
References: <1376378913-879-1-git-send-email-hayeswang@realtek.com>
 <1376484880-741-1-git-send-email-hayeswang@realtek.com>
 <20130815122617.GA18057@electric-eye.fr.zoreil.com>
 <4C3BE5B36641404DBF9ED8943729871B@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "'nic_swsd'" <nic_swsd@realtek.com>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	"'David Miller'" <davem@davemloft.net>
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C3BE5B36641404DBF9ED8943729871B@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
> Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> > The forward declaration is not needed.
> 
> The r8152_submit_rx() need the declaration of read_bulk_callback(), and the
> read_bulk_callback() need the declaration of r8152_submit_rx(), too. It likes
> a dead lock, so I have no idea how to do it without another declaration.

Ok, send me a brain for Xmas.

[...]
> > How is it related to the subject of the patch ?
> 
> When link down, the driver would cancel all bulks. This avoid the re-submitting
> bulk.

It's quite orthogonal to aggregation and could thus had been done in its own
patch for readability sake.

[...]
> > It should be possible to retrieve more items in the spinlocked section
> > so as to have a chance to batch more work. I have not thought 
> > too deeply
> > about it.
> 
> I only lock when I want to remove or inser the agg list, and unlock as soon as
> possible. I don't think I keep locking for a long time.

Sure. It doesn't make a difference if tp->rx_done doesn't grow much.

Thanks.

-- 
Ueimor
