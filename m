From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Problem with ebtables target that changes frame protocol
Date: Tue, 24 Feb 2004 22:47:20 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200402242247.20875.bdschuym@pandora.be>
References: <AC8C1F46CD753F4AAC8F890E35A9EB461C66EB@webmail.instant802.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Simon Barber" <simon@instant802.com>,
	"Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<netdev@oss.sgi.com>
In-Reply-To: <AC8C1F46CD753F4AAC8F890E35A9EB461C66EB@webmail.instant802.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

On Monday 23 February 2004 23:41, Simon Barber wrote:
> I have written an ebtables target that changes the ethernet protocol of
> a received frame (it runs in the broute chain). I have been working on
> 2.4.21 sources - Unfortunately inside netif_rx the skb->protocol is
> looked at before the bridge code is called - and then acted upon after.
> Hence if the bridge code changes the protocol the incorrect protocol is
> used to process the frame.

As the variable type is only used after the bridge code, I think it is best to 
postpone the initialization of type until after the bridge code. This is of 
course of no concern to the standard 2.4 kernel (as ebtables isn't in 2.4). 
This problem exists in the 2.6 kernel, however.
I'll make a fix for 2.6 later, unless someone beats me to it. I'm kind of busy 
at the moment.

cheers,
Bart
