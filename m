From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [ANNOUNCE] libnftnl 1.0.4 release
Date: Wed, 16 Sep 2015 14:07:52 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1509161400550.18792@nerf40.vanv.qr>
References: <20150916115004.GA1102@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, netfilter-announce@lists.netfilter.org,
	lwn@lwn.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20150916115004.GA1102@salvia>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2015-09-16 13:50, Pablo Neira Ayuso wrote:
>The Netfilter project proudly presents:
>
>        libnftnl 1.0.4

$ git diff libnftnl-1.0.3..libnftnl-1.0.4 src/libnftnl.map
diff --git a/src/libnftnl.map b/src/libnftnl.map
index be7b998..14ec88c 100644
--- a/src/libnftnl.map
+++ b/src/libnftnl.map
@@ -124,10 +123,12 @@ global:
   nft_set_attr_is_set;
   nft_set_attr_set;
   nft_set_attr_set_u32;
+  nft_set_attr_set_u64;
   nft_set_attr_set_str;
   nft_set_attr_get;
   nft_set_attr_get_str;
   nft_set_attr_get_u32;
+  nft_set_attr_get_u64;
   nft_set_nlmsg_build_payload;
   nft_set_nlmsg_parse;
   nft_set_parse;

You broke the ABI. A program that uses nft_set_attr_set_u64 and is
built against libnftnl-1.0.4 is marked to be compatible with the
"LIBNFTNL_1.0" symbol group, but this is incorrect, since the
nft_set_attr_set_u64 symbol did not previously exist.

Existing symbol groups in .map must not be extended. Always start
a new group.
