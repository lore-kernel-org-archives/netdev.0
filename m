From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] drivers:net:wireless: Add mutex locking for function,
 b43_op_beacon_set_time in main.c
Date: Sat, 29 Nov 2014 09:54:29 +0100
Message-ID: <CACna6rzfZjKg4diAEE9hFcN5DFadhxC-Uv9aS1RDMXmJ4zbgVQ@mail.gmail.com>
References: <1417213013-19758-1-git-send-email-xerofoify@gmail.com>
	<CACna6rxmOC0h9hOpa=5iWFM1THQ8Q4hCi8MnmqkZJbB_U0PJ0A@mail.gmail.com>
	<20141129002148.1beb21d9@wiggum>
	<54793E4E.7050602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Michael_B=C3=BCsch?= <m@bues.ch>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Network Development <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	b43-dev <b43-dev@lists.infradead.org>
To: nick <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54793E4E.7050602@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29 November 2014 at 04:32, nick <xerofoify@gmail.com> wrote:
> I don't have hardware for this driver on me, so I didn't test it. However this seems to
> be correct from my reading of the code around this function and other locking related
> to this driver.

So do you say it's not executed in an atomic?

>From *early* look it seems b43_update_templates is called from
b43_op_beacon_set_tim and b43_op_bss_info_changed, both or them are
mac80211 callbacks. That also should be safe, however I didn't check
if it may conflict with some in-kernel code (still, assuming it's not
atomic code, which I don't know!).
