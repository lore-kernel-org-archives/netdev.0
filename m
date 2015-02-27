From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Fri, 27 Feb 2015 19:14:47 +0100
Message-ID: <20150227181447.GA11594@localhost.localdomain>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
 <20150225151945.GB7703@localhost.localdomain>
 <20150225170127.GD7703@localhost.localdomain>
 <54EE0268.2040201@linn.co.uk>
 <20150225173053.GE7703@localhost.localdomain>
 <54F0A4C4.3020407@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <54F0A4C4.3020407-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 27, 2015 at 05:09:24PM +0000, Stathis Voukelatos wrote:
> To summarize (and confirm my understanding) your suggestion is for the
> sniffer to be configured to match PTP packets and (similarly to the
> dp83640) return the Message Type and Sequence Id fields that will allow
> them to be matched to an sk_buf that has been passed from the stack.
> Then the sk_buf can be timestamped using the sniffer timestamp.

Yes.
 
> The H/W does have the capability to do that. However, in order to
> implement it there will be some architectural changes needed
> in the kernel. This module cannot really pretend to be a PHY.
> In the real world it sits between the MAC and the PHY.

Right.

Here is one idea.  Put a link to the TS device in the PHY's DT node.
Then, in phy_probe, check if the PHY's four methods, ts_info,
hwtstamp, rxtstamp, and txtstamp, are all null.  If so, check for a DT
link from the PHY's node to a TS device driver.  If found, then set
the four methods to call into the TS driver's callbacks.

Just off of the top of my head.

Thanks,
Richard
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
