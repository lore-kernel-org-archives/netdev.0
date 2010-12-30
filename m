From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: [net-next-2.6 PATCH v2 0/4] dcbnl: Extending dcbnl to support
 non-host DCBX
Date: Thu, 30 Dec 2010 18:26:42 +0200
Message-ID: <1293726402.29378.91.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"John Fastabend" <john.r.fastabend@intel.com>, lucy.liu@intel.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3122 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab0L3Q1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 11:27:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCBX is the exchange protocol for negotiating DCB parameters between a
host and a switch. In some circumstances the DCBX negotiator can not
reside in the host directly on top of the networking interface. For
instance many converged network adapters support an embedded DCBX engine
that performs the negotiation and configures the device with the
negotiated parameters. Another example is virtual hosts and SRIOV
virtual functions.

The following patches extend the dcbnl netlink interface so in addition
to its current semantics it offers a standard mechanism for managing
such non-host DCBX engines. In this new mode 'set' operations are used
to set the initial negotiation configuration and the 'get' operation are
used to retrieve the negotiated results. 

The current definition of dcbnl assumes a host based stack is performing
the negotiation. As DCBX is encapsulated by LLDP there can be only one
DCBX negotiator per physical link. Thus the current scheme does not
allow the coexistence of CNAs that have embedded DCBX engines and CNAs
that do not, or even just retrieving DCB parameters by VF drivers.

The last patch adds an implementation of the dcbnl operations in their
proposed new semantics to the bnx2x, allowing users to configure and
manage the embedded DCBX engine.

The entire patch series is dependent on the following patches:
[net-next-2.6 PATCH 1/3] dcbnl: add support for ieee8021Qaz attributes
[net-next-2.6 PATCH 2/3] dcbnl: add appliction tlv handlers
[net-next-2.6 PATCH 3/3] net_dcb: add application notifiers



