From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mount gives ENETDOWN in -git15
Date: Sun, 22 Jul 2007 13:55:16 -0400
Message-ID: <1185126916.6577.6.camel@localhost>
References: <200707211531.17750.ak@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-j27T8iKe8B8FKEoe0c32"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46658 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751325AbXGVRzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2007 13:55:20 -0400
In-Reply-To: <200707211531.17750.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-j27T8iKe8B8FKEoe0c32
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, 2007-07-21 at 15:31 +0200, Andi Kleen wrote:
> I tried to mount another nfs mount on a system running with nfsroot.
> But I get
> 
> # mount basil:/home /basil/home/
> mount: Network is down
> 
> The network is not down of course, the system is happily running with nfs root from that
> server. Userland is older SUSE 10.0

Does Al's patch help in any way?

Cheers
  Trond


--=-j27T8iKe8B8FKEoe0c32
Content-Disposition: inline
Content-Description: Attached message - [PATCH] fix broken handling of
	port=... in NFS option parsing
Content-Type: message/rfc822

Received: from exsvlrb01.hq.netapp.com ([10.56.8.62]) by
	exsvl03.hq.netapp.com with Microsoft SMTPSVC(6.0.3790.1830); Sun, 22 Jul
	2007 02:59:13 -0700
Received: from sacexrs01.hq.netapp.com ([10.99.190.105]) by
	exsvlrb01.hq.netapp.com with Microsoft SMTPSVC(6.0.3790.1830); Sun, 22 Jul
	2007 02:59:13 -0700
Received: from smtp1.corp.netapp.com ([10.57.156.124]) by
	sacexrs01.hq.netapp.com with Microsoft SMTPSVC(6.0.3790.1830); Sun, 22 Jul
	2007 02:59:12 -0700
Received: from mx1.netapp.com (mx1.dmz.netapp.com [10.254.64.60]) by
	smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id l6M9xBYt020931
	for <Trond.Myklebust@netapp.com>; Sun, 22 Jul 2007 02:59:12 -0700 (PDT)
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: AgAAALrHokbDXP0ChGdsb2JhbACPWQEBCQoPGA
X-IronPort-AV: E=Sophos;i="4.16,568,1175497200";  d="scan'208";a="89214520"
X-SBRS: 3.2
Received: from zeniv.linux.org.uk ([195.92.253.2]) by mx1.netapp.com with
	ESMTP/TLS/DHE-RSA-AES256-SHA; 22 Jul 2007 02:59:11 -0700
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.52 #1 (Red Hat
	Linux)) id 1ICYDS-0003JE-Pw; Sun, 22 Jul 2007 10:59:06 +0100
Date: Sun, 22 Jul 2007 10:59:06 +0100
From: Al Viro <viro@ftp.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org
Subject: [PATCH] fix broken handling of port=... in NFS option parsing
Message-ID: <20070722095906.GX21668@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.4.1i
Return-Path: viro@ftp.linux.org.uk
X-OriginalArrivalTime: 22 Jul 2007 09:59:12.0704 (UTC)
	FILETIME=[F49CC400:01C7CC46]
X-Evolution-Source: exchange://trond;auth=NTLM@exsvl03.hq.netapp.com/
Content-Transfer-Encoding: 7bit

	Obviously broken on little-endian; fortunately, the option is
not frequently used...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b34b7a7..b2a851c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -732,7 +732,7 @@ static int nfs_parse_mount_options(char *raw,
 				return 0;
 			if (option < 0 || option > 65535)
 				return 0;
-			mnt->nfs_server.address.sin_port = htonl(option);
+			mnt->nfs_server.address.sin_port = htons(option);
 			break;
 		case Opt_rsize:
 			if (match_int(args, &mnt->rsize))

--=-j27T8iKe8B8FKEoe0c32--

