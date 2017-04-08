From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 0/5] extended netlink ACK reporting
Date: Sat,  8 Apr 2017 19:48:55 +0200
Message-ID: <20170408174900.12820-1-johannes@sipsolutions.net>
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

After testing and fixing the ack message length calculation,
this now works.

The UAPI changes are like before - the ACK message format becomes
 [nlmsg header]
 [ack header]
 [request nlmsg header]
 [request nlmsg body (already optional) - length aligned]
 [extended ACK TLVs - this is NEW]

The extended ACK TLVs currently are:
For the error case:
 * MSG - string message
 * OFFS - offset of problem (e.g. malformed attribute)
          in the request message
 * ATTR - missing attribute ID
For the success case:
 * COOKIE - arbitrary per-subsystem cookie to identify
            the newly created object or similar

The whole behaviour can be enabled/disabled/queried using
a new socket option NETLINK_EXT_ACK.

johannes
