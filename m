From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] linux 2.9.10-rc1: Fix oops in unix_dgram_sendmsg when
 using SELinux and SOCK_SEQPACKET
Date: Thu, 18 Nov 2004 12:01:34 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0411181158110.5096-100000@thoron.boston.redhat.com>
References: <20041118084449.Z14339@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ross Kendall Axe <ross.axe@blueyonder.co.uk>, <netdev@oss.sgi.com>,
	Stephen Smalley <sds@epoch.ncsc.mil>,
	lkml <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262778AbUKRRCM@vger.kernel.org>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20041118084449.Z14339@build.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Nov 2004, Chris Wright wrote:

> Why not make a unix_seq_sendmsg, which is a very small wrapper?

Good idea, patch forthcoming.

> Does the above stop the other issue?  My laptop died, so I'm not able to
> test ATM.

No, it seems to be caused when addrlen in sendto() is non-zero, causing 
unix_find_other() to be called instead of unix_peer_get(), which is 
screwing up reference counts.

As for MSG_EOR, apart from the generic socket code, nothing is being done.  
This would be a separate issue.


- James
-- 
James Morris
<jmorris@redhat.com>
