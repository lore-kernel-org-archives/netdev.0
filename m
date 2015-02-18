From: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Subject: Re: [PATCH v2 2/3] Packet sniffer core framework
Date: Wed, 18 Feb 2015 16:44:19 +0000
Message-ID: <54E4C163.4020702@linn.co.uk>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk> <9202ff9a629935ada672415bf071a1cf31ac09b6.1424181053.git.stathis.voukelatos@linn.co.uk> <54E4B2CE.2090104@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54E4B2CE.2090104-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

On 18/02/15 15:42, Daniel Borkmann wrote:
>
> This whole framework really looks like only tailored to your specific
> driver, I have no idea who else should reuse that?! So, I don't think
> putting this under drivers/net/pkt-sniffer/ is a good idea.
>

Yes, it is not necessarilly expected to be used by other 3rd party 
drivers. The reason of splitting out the framework code is to account of 
the fact the we may develop in the future othersimilar sniffer H/W for 
non-ethernet interfaces (eg. wifi).
I can move the code under drivers/net/ethernet/linn as you mention 
below, although that may not account for non-ethernet backends in the
future.

> Also it looks slightly confusing as if I understand you correctly, your
> module's purpose is to pass down some "packet pattern" to the hardware
> and match that in order to get a precise timestamp in return?
>

Yes, this point can be slightly confusing. A write to a packet socket 
bound to the interface is done to supply the command string to the 
sniffer H/W, while reads would return matched packet bytes + timestamps 
(throuch cmsg). Is there any other way to supply the command string 
except of a proprietary ioctl?

> Might perhaps be better to have everything vendor-specific under something
> like drivers/net/ethernet/linn/ and have the framework squashed into the
> driver itself (if parts cannot be generalized in net/packet/).
>

Answered above.

> It would be good if you can also avoid the extra uapi export. Perhaps
> it's possible to reuse at least some of the existing timestamping
> infrastructure?

I can remove that. The header file only contains the list of commands.
They can be documented. The driver does use the existing timestamping
infrastructure to return timestamps to user space.

Thank you,
Stathis
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
