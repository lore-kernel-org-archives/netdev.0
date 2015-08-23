From: Christophe Ricard <christophe.ricard@gmail.com>
Subject: [RFC] netlink_ack: send a capped message in case of error
Date: Mon, 24 Aug 2015 00:06:16 +0200
Message-ID: <1440367577-15786-1-git-send-email-christophe-h.ricard@st.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Christophe Ricard <christophe-h.ricard@st.com>
To: pablo@netfilter.org, jbenc@redhat.com, sameo@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35979 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759AbbHWWGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 18:06:23 -0400
Received: by wicja10 with SMTP id ja10so56168659wic.1
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 15:06:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have found with netlink we can miss a ack message when exchanging large buffers.
I came across this "bug ?" when doing some tests on the NFC subsytem by trying to
send extended APDU to a secure element (up to 65K) or when sending specific device
firmware data (up to 8K) (NFC_ATTR_SE_APDU & NFC_ATTR_VENDOR_DATA).

After some search on the web, i found this topic was already threated by Jiri Benc in November 2013: 
- http://patchwork.ozlabs.org/patch/290976/
- http://www.spinics.net/lists/netdev/msg256938.html

I haven't found any update or any fix in recent kernel.

I liked the netlink message cap approach.

Do you have any update ?
Do you think a netlink message cap in netlink_ack in case of an error is an acceptable approach ?

Best Regards
Christophe

Christophe Ricard (1):
  netlink: netlink_ack send a capped message in case of error

 net/netlink/af_netlink.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

-- 
2.1.4
