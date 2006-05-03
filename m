From: Jiri Benc <jbenc@suse.cz>
Subject: Re: net/d80211 and management interface (wmaster0ap)
Date: Wed, 3 May 2006 14:08:26 +0200
Message-ID: <20060503140826.0a5df04a@griffin.suse.cz>
References: <20060502183930.GA28777@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44965 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965162AbWECMI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 08:08:29 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060502183930.GA28777@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 May 2006 11:39:30 -0700, Jouni Malinen wrote:
> It looks like one of your patches in wireless-dev.git broke management
> interface. I'm not completely sure about how this was supposed to work,
> but are the low-level drivers now expected to accept
> IEEE80211_IF_TYPE_MGMT in add_interface handler or should ieee80211.c be
> modified to accept wmaster0ap to be set UP without asking the low-level
> driver?

It shouldn't ask the driver. This was a part of the dropped patch for
removing default management device. I will send a patch to address this
particular issue later today.

> In addition to this, it looked like sending packets from wmaster0ap did
> not work. The packets were being dropped since originating device
> (wmaster0ap) did not match in is_ieee80211_device(). This function
> seemed to use wireless_handlers pointer for recognizing interfaces which
> (like to comment says) is not that nice. wireless_handlers were not set
> for apdev, so the patch below adds it to make TX work through
> wmaster0ap.

Oh, thanks for finding this. But we probably don't want wmaster0ap to
have wireless_handlers set. I will try to rewrite is_ieee80211_device in
some another way.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
