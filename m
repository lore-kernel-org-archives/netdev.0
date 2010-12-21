From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [PATCH net-next 0/3] dcbnl: Extending dcbnl to support HW based
 DCBX
Date: Tue, 21 Dec 2010 21:32:35 +0200
Message-ID: <1292959955.7142.129.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, lucy.liu@intel.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4636 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752650Ab0LUTcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 14:32:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCBX is the exchange protocol for negotiating DCB parameters between a
host and a switch. Many converged network adapters support an embedded
DCBX engine that performs the negotiation and configures the device
with the negotiated parameters. The following patches extend the dcbnl
netlink interface so in addition to its current semantics it offers a
standard mechanism for managing such embedded DCBX engines. In this new
mode 'set' operations are used to set the initial negotiation
configuration and the 'get' operation are used to retrieve the
negotiated results. 

The current definition of dcbnl allows a user to configure the device
with the negotiated parameters only after the negotiation itself is
performed by an external entity (such as lldpad). As DCBX runs on top
of LLDP, there can be only one entity responsible for the negotiation
for each physical port. Thus the current scheme does not allow the
coexistence of CNAs that have embedded DCBX engines and CNAs that do
not.

The last patch adds an implementation of the dcbnl operations in their
proposed new semantics to the bnx2x, allowing users to configure and
manage the embedded DCBX engine.


