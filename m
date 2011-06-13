From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: avoid using uninitialized variable
Date: Mon, 13 Jun 2011 18:12:12 -0400
Message-ID: <20110613181212.571f8e76@s6510.ftrdhcpuser.net>
References: <xr93vcw9s9zc.fsf@gthelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Thelen <gthelen@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <xr93vcw9s9zc.fsf@gthelen.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Jun 2011 14:21:59 -0700
Greg Thelen <gthelen@google.com> wrote:

> I am not sure if 0 or ~0 would be a better choice in the gm_phy_read()
> error case.  I used 0.  A more complete solution might be to plumb up
> error handling to the callers of gm_phy_read().
> 
> ==
> From 37486219a3d93881f3b2619a4b2bb21be62db7d4 Mon Sep 17 00:00:00 2001
> From: Greg Thelen <gthelen@google.com>
> Date: Mon, 13 Jun 2011 14:09:07 -0700
> Subject: [PATCH] sky2: avoid using uninitialized variable
> 
> Prior to this change gm_phy_read() could return an uninitialized
> variable if __gm_phy_read() failed.
> 
> This change returns zero in the failure case.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Shouldn't the callers be changed to check rather than just returning
0 and masking the problem.
