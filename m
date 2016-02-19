From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v2 0/3] lwtunnel: autoload of lwt modules
Date: Fri, 19 Feb 2016 09:43:15 +0000
Message-ID: <1455874998-26795-1-git-send-email-rshearma@brocade.com>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Tom Herbert" <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jiri Benc <jbenc@redhat.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:62170 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161131AbcBSJnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 04:43:50 -0500
In-Reply-To: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v1:
 - remove "LWTUNNEL_ENCAP_" prefix for the string form of the encaps
   used when requesting the module to reduce duplication, and don't
   bother returning strings for lwt modules using netdevices, both
   suggested by Jiri.
 - update commit message of first patch to clarify security
   implications, in response to Eric's comments.

The lwt implementations using net devices can autoload using the
existing mechanism using IFLA_INFO_KIND. However, there's no mechanism
that lwt modules not using net devices can use.

Therefore, these patches add the ability to autoload modules
registering lwt operations for lwt implementations not using a net
device so that users don't have to manually load the modules.

Robert Shearman (3):
  lwtunnel: autoload of lwt modules
  mpls: autoload lwt module
  ila: autoload module

 include/net/lwtunnel.h    |  4 +++-
 net/core/lwtunnel.c       | 37 +++++++++++++++++++++++++++++++++++++
 net/ipv6/ila/ila_common.c |  1 +
 net/mpls/mpls_iptunnel.c  |  1 +
 4 files changed, 42 insertions(+), 1 deletion(-)

-- 
2.1.4
