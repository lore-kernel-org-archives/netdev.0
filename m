From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2/3] cnic: Add CNIC driver.
Date: Fri, 23 May 2008 17:42:35 -0700
Message-ID: <1211589755.18326.95.camel@dell>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com>
 <1211418386-18203-3-git-send-email-mchan@broadcom.com>
 <adad4nc7p6p.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, michaelc@cs.wisc.edu,
	anilgv@broadcom.com, netdev <netdev@vger.kernel.org>,
	linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <adad4nc7p6p.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-05-23 at 13:14 -0700, Roland Dreier wrote:
>  > +		/* Tell compiler that status_blk fields can change. */
>  > +		barrier();
>  > +		if (status_idx != sblk->status_idx) {
> 
> Is a compiler barrier sufficient here?  It seems an out-of-order CPU
> could still mess things up, so an rmb() or smp_rmb() would be required.
> 

The purpose of this compiler barrier is to make sure that the compiled
code will get the sblk->status_idx from memory which may change if the
chip DMAs a new status_idx.

This code is inside a while loop, so it is possible that the compiler
can optimize it to not load status_idx from memory.

Thanks.

