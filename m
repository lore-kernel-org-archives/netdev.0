From: Peter Wu <peter@lekensteyn.nl>
Subject: Re: [PATCH] net: wireless: rtlwifi: rtl8192de: hw.c: Cleaning up conjunction always evaluates to false
Date: Sun, 08 Jun 2014 11:26:50 +0200
Message-ID: <1436639.AmJiDmeQZF@al>
References: <1402151419-18296-1-git-send-email-rickard_strandqvist@spectrumdigital.se> <CAFo99gZ+iu3FA9Nuwdo_AT1xZkno7w=6JidWYcm8g0bOvshwTw@mail.gmail.com> <5393A7D0.2080700@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lekensteyn.nl ([178.21.112.251]:37259 "EHLO lekensteyn.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbaFHJ1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 05:27:07 -0400
In-Reply-To: <5393A7D0.2080700@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 07 June 2014 19:01:20 Larry Finger wrote:
> As you have learned here, automatically making changes suggested by some tool 
> may convert a visible bug into one that is invisible, and only found by a 
> detailed line-by-line examination of the code, and that is unlikely to happen. 
> Please be careful.
> 
>  From everything I see, the test in all drivers should be
> 
>         if ((bt_msr & MSR_AP) == MSR_AP)

That only happens to be case because MSR_INFRA | MSR_ADHOC == MSR_AP. This
seems to be the intent:

    #define MSR_MASK 0x03
    if ((bt_msr & MSR_MASK) == MSR_AP)

In rtl8192se, there are also MSR_LINK_... constants covering MSR_...
and in addition, there is a MSR_LINK_MASK. These macros are quite
redundant though given the other definitions, but the mask is still
nice to have I guess.

Also, personally I would submit just one patch touching all drivers, but
I see that Rickard has submitted a bunch of patches (without cover letter
either, making it more difficult to group them). What would you prefer,
a single patch touching multiple drivers (as the changes are mostly the
same) or split patches?

Kind regards,
Peter
