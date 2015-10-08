From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] af_unix: introduce unix_sk_const helper
Date: Thu, 08 Oct 2015 14:11:41 +0200
Message-ID: <5878507.y5cIDTsIKy@wuerfel>
References: <10735490.HC94hyceBX@wuerfel> <20151008.040332.1651208312284048708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, aconole@bytheb.org, edumazet@google.com,
	james.l.morris@oracle.com, linux-security-module@vger.kernel.org,
	serge@hallyn.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151008.040332.1651208312284048708.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 October 2015 04:03:32 David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Tue, 06 Oct 2015 22:52:46 +0200
> 
> > Commit 124613012db1 ("af_unix: Convert the unix_sk macro to an inline
> > function for type safety") was recently added to catch incorrect
> > uses of the unix_sk helper using compiler warnings.
> > 
> > It has now caught one such case in lsm_audit.c. The code is technically
> > correct, but as it converts a const pointer to a non-const pointer,
> > the annotation got lost, which gcc now warns about.
> > 
> > This patch avoids the warning by introducing an additional helper
> > that has const input and output, which makes the lsm_audit code build
> > cleanly again.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> > I'm not entirely happy with this workaround myself, but could not come
> > up with a better one.
> 
> You can make the argument unconditionally const, as Paul Moore has done
> in a separate patch submission.

Ok, I see now how Paul's "audit: constify parts of common_audit_data and lsm_network_audit" patch caused the problem and is now gone from linux-next.
That seems nicer indeed.

	Arnd
