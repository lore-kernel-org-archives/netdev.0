From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH V2] sctp: not send SCTP_PEER_ADDR_CHANGE notifications with failed probe
Date: Wed, 20 Aug 2014 17:31:42 +0800
Message-ID: <1408527103-22772-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: dborkman@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, vyasevich@gmail.com, tuexen@fh-muenster.de,
	khandelwal.deepak.1987@gmail.com, Yue.Tao@windriver.com,
	alexandre.dietsch@windriver.com, davem@davemloft.net,
	zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:39719 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbaHTJcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 05:32:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Vlad && Deepak && Michael && David && Daniel

V2: Following the advice from Daniel Borkmann, I modified the comments and short log.

>From Michael && Deepak
"
 lxr SCTP implementation, doesn't transit the path state to INACTIVE, if it was never confirmed. this leads to SCTP_PEER_ADDRESS_CHANGE notification after each failed probe from this time.
 Is there any specific reason to have same notification to SCTP User with each probe in RTO time period ?
 806 case SCTP_TRANSPORT_DOWN:
 807 /* If the transport was never confirmed, do not transition it
 808 * to inactive state. Also, release the cached route since
 809 * there may be a better route next time.
 810 */
 811 if (transport->state != SCTP_UNCONFIRMED)

 812 transport->state = SCTP_INACTIVE;

 http://lxr.free-electrons.com/source/net/sctp/associola.c#L806

 ......

 I would also only expect a  SCTP_PEER_ADDRESS_CHANGE notification when a path state changes, not on every  try.

"

I made a patch to disable sending SCTP_PEER_ADDRESS_CHANGE notification every try. Now the patch is in the attachment. Please check it.

Zhu Yanjun


Zhu Yanjun (1):
  sctp: not send SCTP_PEER_ADDR_CHANGE notifications with failed probe

 net/sctp/associola.c | 1 +
 1 file changed, 1 insertion(+)

-- 
1.9.1
