From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Mon, 10 Apr 2017 17:40:11 +0200
Message-ID: <1491838811.28432.8.camel@sipsolutions.net>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
         <20170408202434.12018-2-johannes@sipsolutions.net>
         <fddba2c8-3b85-d5df-81c4-ef31c459e40c@cumulusnetworks.com>
         <1491838218.28432.5.camel@sipsolutions.net>
         <029e6587-c0e8-bdb0-49e9-2abe2946a7ff@cumulusnetworks.com>
         (sfid-20170410_173530_723869_8DC854E1)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <029e6587-c0e8-bdb0-49e9-2abe2946a7ff-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org> (sfid-20170410_173530_723869_8DC854E1)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-04-10 at 09:35 -0600, David Ahern wrote:

> > Do you have any better ideas?
> 
> NETLINK_F_CAP_ACK and NETLINK_F_EXT_ACK should be incompatible -- if
> one is set the other can not be set. CAP_ACK means abbreviate the
> response and EXT_ACK means give me more data.

So you mean if I want EXT_ACK I cannot also cap the message?

I guess that's doable, but again wouldn't it hurt applications that
want to use CAP? I assume every application wants to use EXT_ACK
eventually, and those that use CAP right now wouldn't be able to.

Another thought: if we add a new flag that indicates "message has been
capped", which we introduce in this same patch, then we can disentangle
this more easily, right?

Adding a new flag for "TLVs present" won't really help, but if you know
the message was capped then you know the TLVs start after the inner
nlmsghdr and you ignore that header's nlmsg_len.

johannes
