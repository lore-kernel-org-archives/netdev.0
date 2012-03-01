From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/4] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Thu, 1 Mar 2012 12:27:32 +0100
Message-ID: <20120301112732.GA6806@1984>
References: <1328400892-22409-1-git-send-email-richard@nod.at>
 <1328400892-22409-3-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1328400892-22409-3-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 05, 2012 at 01:14:48AM +0100, Richard Weinberger wrote:
> ipt_LOG and ip6_LOG have a lot of common code, merge them
> to reduce duplicate code.
> 
> Signed-off-by: Richard Weinberger <richard@nod.at>

While testing this in my master branch I noticed one problem:

IN=wlan0 OUT= MAC=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
SRC=213.150.61.61 DST=192.168.1.133 LEN=40 TOS=0x00 PREC=0x00 TTL=117
ID=10539 DF PROTO=TCP SPT=80 DPT=49013 WINDOW=0 RES=0x00 ACK RST
URGP=0 PROTO=UDPLITE SPT=80 DPT=49013 LEN=45843 PROTO=ICMP TYPE=0
CODE=80 ID=45843 SEQ=48576

While merging ipt_LOG and ip6t_LOG, you introduced some bug that
corrupts the log line. Note the extra PROTO=, I don't have any UDPLITE
traffic here.

Looks like a missing break in one switch.

Would you send me a patch to fix this?

Thank you.
