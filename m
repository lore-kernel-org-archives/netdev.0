From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 1/4] ethtool: remove strings based approach for
	displaying n-tuple
Date: Tue, 03 May 2011 09:12:10 -0700
Message-ID: <20110503161210.29251.54634.stgit@gitlad.jf.intel.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59966 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290Ab1ECQMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 12:12:13 -0400
In-Reply-To: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to remove the strings based approach for displaying
n-tuple filters.  A follow-on patch will replace that functionality with a
network flow classification based approach that will get the number of
filters, get their locations, and then request and display them
individually.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool.c |   44 --------------------------------------------
 1 files changed, 0 insertions(+), 44 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index cfdac65..9ad7000 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3194,50 +3194,6 @@ static int do_srxntuple(int fd, struct ifreq *ifr)
 
 static int do_grxntuple(int fd, struct ifreq *ifr)
 {
-	struct ethtool_sset_info *sset_info;
-	struct ethtool_gstrings *strings;
-	int sz_str, n_strings, err, i;
-
-	sset_info = malloc(sizeof(struct ethtool_sset_info) + sizeof(u32));
-	sset_info->cmd = ETHTOOL_GSSET_INFO;
-	sset_info->sset_mask = (1ULL << ETH_SS_NTUPLE_FILTERS);
-	ifr->ifr_data = (caddr_t)sset_info;
-	err = send_ioctl(fd, ifr);
-
-	if ((err < 0) ||
-	    (!(sset_info->sset_mask & (1ULL << ETH_SS_NTUPLE_FILTERS)))) {
-		perror("Cannot get driver strings info");
-		return 100;
-	}
-
-	n_strings = sset_info->data[0];
-	free(sset_info);
-	sz_str = n_strings * ETH_GSTRING_LEN;
-
-	strings = calloc(1, sz_str + sizeof(struct ethtool_gstrings));
-	if (!strings) {
-		fprintf(stderr, "no memory available\n");
-		return 95;
-	}
-
-	strings->cmd = ETHTOOL_GRXNTUPLE;
-	strings->string_set = ETH_SS_NTUPLE_FILTERS;
-	strings->len = n_strings;
-	ifr->ifr_data = (caddr_t) strings;
-	err = send_ioctl(fd, ifr);
-	if (err < 0) {
-		perror("Cannot get Rx n-tuple information");
-		free(strings);
-		return 101;
-	}
-
-	n_strings = strings->len;
-	fprintf(stdout, "Rx n-tuple filters:\n");
-	for (i = 0; i < n_strings; i++)
-		fprintf(stdout, "%s", &strings->data[i * ETH_GSTRING_LEN]);
-
-	free(strings);
-
 	return 0;
 }
 

