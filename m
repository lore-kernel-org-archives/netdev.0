From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RDS: IB: ensure an initialized ret is printed in
 pr_warn message
Date: Fri, 07 Apr 2017 06:10:12 -0700 (PDT)
Message-ID: <20170407.061012.962256066660810702.davem@davemloft.net>
References: <20170407075723.9669-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170407075723.9669-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri,  7 Apr 2017 08:57:23 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> There is a path where ibmr is null and ret has not been initialized
> and hence a pr_warn message is printing an uninitialized value in
> ret.  Fix this by initializing ret to zero.
> 
> Detected by CoverityScan, CID#1357946 ("Uninitialized scalar variable")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

These are exactly the kinds of CoverityScan fixes I really do not want
to see.

Initializing ret to zero is not going to fix the problem.

This function gets error pointers back from the functions that are
used to obtain the ibmr pointer.  Therefore if there is a problem
ibmr won't be NULL, it will be an error pointer.

Therefore, the real problem is that the code isn't checking if
ibmr encodes error value.
