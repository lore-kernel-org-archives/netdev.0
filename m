From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: sctp: not send SCTP_PEER_ADDR_CHANGE notifications with failed probe
Date: Fri, 15 Aug 2014 17:26:59 +0800
Message-ID: <1408094820-11725-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	vyasevich@gmail.com, tuexen@fh-muenster.de,
	khandelwal.deepak.1987@gmail.com, Yue.Tao@windriver.com,
	alexandre.dietsch@windriver.com, davem@davemloft.net,
	zyjzyj2000@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Vlad && DEEPAK && Michael && David

>From Michael && DEEPAK
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

 we checked RFC and here it is mentioned as  Path Verification Section(5.4) of RFC 4960  http://tools.ietf.org/html/rfc4960

 In each RTO, a probe may be sent on an active UNCONFIRMED path in an
 attempt to move it to the CONFIRMED state. If during this probing
 the path becomes inactive, this rate is lowered to the normal
 HEARTBEAT rate. At the expiration of the RTO timer, the error
 counter of any path that was probed but not CONFIRMED is incremented
 by one and subjected to path failure detection, as defined in
 Section


 8.2
 . When probing UNCONFIRMED addresses, however, the association
 overall error counter is not incremented


 Does this mean that in attempt to move a UNCONFIRMED path to CONFIRMED State, the path can become INACTIVE, when transport error counter reaches to path_max_retrans counter ?
 I would say that the path stays UNCONFIRMED.


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
