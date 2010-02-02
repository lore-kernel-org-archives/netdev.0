From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/02: nf_conntrack_sip: fix off-by-one in compact header parsing
Date: Tue,  2 Feb 2010 17:27:38 +0100 (MET)
Message-ID: <20100202162738.24867.16195.sendpatchset@x2.localnet>
References: <20100202162736.24867.67227.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100202162736.24867.67227.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 135d01899b1fba17045961febff7e5141db6048f
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jan 19 19:06:59 2010 +0100

    netfilter: nf_conntrack_sip: fix off-by-one in compact header parsing
    
    In a string like "v:SIP/2.0..." it was checking for !isalpha('S') when it
    meant to be inspecting the ':'.
    
    Patch by Greg Alexander <greqcs@galexander.org>
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 4b57216..023966b 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -376,7 +376,7 @@ int ct_sip_get_header(const struct nf_conn *ct, const char *dptr,
 			dptr += hdr->len;
 		else if (hdr->cname && limit - dptr >= hdr->clen + 1 &&
 			 strnicmp(dptr, hdr->cname, hdr->clen) == 0 &&
-			 !isalpha(*(dptr + hdr->clen + 1)))
+			 !isalpha(*(dptr + hdr->clen)))
 			dptr += hdr->clen;
 		else
 			continue;
