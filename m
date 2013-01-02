From: Sujith Manoharan <sujith@msujith.org>
Subject: Re: [PATCH] ath9k_htc: Fix skb leaks
Date: Wed, 2 Jan 2013 10:56:37 +0530
Message-ID: <20707.50445.510814.481023@gargle.gargle.HOWL>
References: <1357098567-8558-1-git-send-email-Larry.Finger@lwfinger.net>
	<20707.47067.474241.813195@gargle.gargle.HOWL>
	<50E3BE23.3010102@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	ath9k-devel@lists.ath9k.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <50E3BE23.3010102@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger wrote:
> My only counter argument is that none of the other paths that get to 
> ath9k_htc_txcompletion_cb() leak the skb. It only happens for the path that goes 
> through htc_connect_service().

Sure, but the TX completion handler would be invoked for every skb that is passed
to the USB layer, including the ones that are allocated in htc_hst.c. When this
skb goes down to hif_usb.c, a URB is allocated and I am not sure how freeing
the skb before the USB layer invokes the completion handler for the URB is correct.

I'll come up with a patch and see if kmemleak still complains.

Sujith
